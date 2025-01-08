import CustomDump
import IdentifiedCollections
import IssueReporting
import Perception
import Testing
import WPFoundation
import WPSharing

@Suite("DerivedSharedReaderKey tests")
struct DerivedSharedReaderKeyTests {
  @Test("Derives Value From Shared Reader Key")
  func derivesFromReader() async {
    let key = PersonKey()
    @SharedReader(key) var value = IdentifiedArray()
    let derived = $value.deriveMap(id: \.value.id) { DerivedPerson(value: $0, counter: 10) }

    let newValue = Person(id: UUID(), name: "Baz")
    await key.send(value: [newValue])
    expectNoDifference(
      Array(derived.wrappedValue.identifiedArray),
      [DerivedPerson(value: .constant(newValue), counter: 10)]
    )

    derived.withLock { $0.identifiedArray[0].counter += 1 }

    let newValue2 = Person(id: newValue.id, name: "Blob")
    await key.send(value: [newValue2])
    expectNoDifference(
      Array(derived.wrappedValue.identifiedArray),
      [DerivedPerson(value: .constant(newValue2), counter: 11)]
    )
  }

  @Test("Doesn't Share Derived Value For 2 Key Instances When Names Are Different")
  func doesNotShareDerivedFrom2SeparateKeyNames() async {
    let key = PersonKey()
    @Shared(key) var value = IdentifiedArray()
    let derived = $value.deriveMap(id: \.person.value.id) {
      ReferencedDerivedPerson(person: DerivedPerson(value: $0, counter: 10))
    }

    let newValue = Person(id: UUID(), name: "Baz")
    await key.send(value: [newValue])
    let instance = derived.wrappedValue.identifiedArray[0]

    let derived2 = $value.deriveMap(id: \.person.value.id) {
      ReferencedDerivedPerson(person: DerivedPerson(value: $0, counter: 10))
    }
    expectNoDifference(instance === derived2.wrappedValue.identifiedArray[0], false)
  }

  @Test("Derives Multiple Values From Shared Reader Key")
  func derivesMultipleFromReader() async {
    let key = PersonKey()
    @SharedReader(key) var value = IdentifiedArray()
    let derived = $value.deriveMap(id: \.value.id) { DerivedPerson(value: $0, counter: 10) }

    let newValues = IdentifiedArrayOf(
      uniqueElements: [
        Person(id: UUID(), name: "Baz"),
        Person(id: UUID(), name: "Bar"),
        Person(id: UUID(), name: "Foo")
      ]
    )
    await key.send(value: newValues)
    expectNoDifference(
      Array(derived.wrappedValue.identifiedArray),
      [
        DerivedPerson(value: .constant(newValues[0]), counter: 10),
        DerivedPerson(value: .constant(newValues[1]), counter: 10),
        DerivedPerson(value: .constant(newValues[2]), counter: 10)
      ]
    )

    derived.withLock {
      guard $0.identifiedArray.count > 2 else {
        reportIssue("Count should be greater than 2")
        return
      }
      $0[0].counter += 1
      $0[1].counter += 2
      $0[2].counter -= 1
    }

    let newValues2 = IdentifiedArrayOf(
      uniqueElements: [
        Person(id: newValues[0].id, name: "Blob"),
        Person(id: UUID(), name: "Blob Sr."),
        Person(id: newValues[1].id, name: "Blob Jr.")
      ]
    )

    await key.send(value: newValues2)
    expectNoDifference(
      Array(derived.wrappedValue.identifiedArray),
      [
        DerivedPerson(value: .constant(newValues2[0]), counter: 11),
        DerivedPerson(value: .constant(newValues2[1]), counter: 10),
        DerivedPerson(value: .constant(newValues2[2]), counter: 12)
      ]
    )
  }

  @Test("Reuses Same Class Instance That Don't Need to Be Derived")
  func reusesSameClassInstances() async {
    let key = PersonKey()
    @SharedReader(key) var value = IdentifiedArray()
    let derived = $value.deriveMap(id: \.person.value.id) {
      ReferencedDerivedPerson(person: DerivedPerson(value: $0, counter: 10))
    }

    let id = UUID()
    await key.send(value: [Person(id: id, name: "Baz")])
    expectNoDifference(derived.wrappedValue.identifiedArray.count, 1)
    let instance = derived.wrappedValue.identifiedArray[0]

    await key.send(value: [Person(id: id, name: "Blob")])
    expectNoDifference(instance === derived.wrappedValue.identifiedArray[0], true)
    expectNoDifference(derived.wrappedValue.identifiedArray[0].person.value.name, "Blob")
  }

  @Test("Removes Values From Derived Array When Removed From Base Array")
  func removesFromDerived() async {
    let key = PersonKey()
    @SharedReader(key) var value = IdentifiedArray()

    let derived = $value.deriveMap(id: \.value.id) { DerivedPerson(value: $0, counter: 10) }
    await key.send(value: [Person(id: UUID(), name: "Baz")])
    expectNoDifference(derived.wrappedValue.identifiedArray.count, 1)

    await key.send(value: [])
    expectNoDifference(Array(derived.wrappedValue.identifiedArray), [])
  }

  @Test("Reports Issue When Assigning New Derived Array With Structurally Different Ids")
  func reportsAssignmentIssue() async {
    let key = PersonKey()
    @SharedReader(key) var value = IdentifiedArray()
    let second = Shared(value: IdentifiedArrayOf<Person>())

    let derived = $value.deriveMap(id: \.value.id) { DerivedPerson(value: $0, counter: 10) }
    let derived2 = second.deriveMap(id: \.value.id) { DerivedPerson(value: $0, counter: 10) }
    await key.send(value: [Person(id: UUID(), name: "Baz")])
    withExpectedIssue {
      derived.withLock { $0 = derived2.wrappedValue }
    }
  }
}

private final class PersonKey: SharedKey {
  typealias Value = IdentifiedArrayOf<Person>
  struct ID: Hashable {}

  private let state = Lock(([UUID: (Value) -> Void](), [Value]()))

  var id: ID { ID() }

  func send(value: IdentifiedArrayOf<Person>) async {
    self.state.withLock {
      $0.1.append(value)
      for callback in $0.0.values {
        callback(value)
      }
    }
    await Task.megaYield()
  }

  func load(
    context: LoadContext<IdentifiedArrayOf<Person>>,
    continuation: LoadContinuation<IdentifiedArrayOf<Person>>
  ) {
    continuation.resumeReturningInitialValue()
  }

  func save(
    _ value: IdentifiedArrayOf<Person>,
    context: SaveContext,
    continuation: SaveContinuation
  ) {
    continuation.resume()
  }

  func subscribe(
    context: LoadContext<IdentifiedArrayOf<Person>>,
    subscriber: SharedSubscriber<IdentifiedArrayOf<Person>>
  ) -> SharedSubscription {
    let id = UUID()
    self.state.withLock {
      for buffered in $0.1 {
        subscriber.yield(buffered)
      }
      $0.0[id] = { subscriber.yield($0) }
    }
    return SharedSubscription {
      self.state.withLock { _ = $0.0.removeValue(forKey: id) }
    }
  }
}

private struct Person: Identifiable, Hashable, Sendable {
  let id: UUID
  let name: String
}

extension Person {
  init() {
    self.id = UUID()
    self.name = "Test"
  }
}

private final class ReferencedDerivedPerson: Sendable {
  let person: DerivedPerson

  init(person: DerivedPerson) {
    self.person = person
  }
}

private struct DerivedPerson: Equatable, Sendable {
  @SharedReader var value: Person
  var counter = 0
}
