import IdentifiedCollections
import Perception
import WPDependencies
import WPFoundation
import WPSwiftNavigation

// MARK: - Map

extension _Shareable where Value: _IdentifiedCollection, Value.ID: Sendable {
  public func deriveMap<DerivedValue: Identifiable>(
    _ fn: @Sendable @escaping (SharedReader<Value.Element>) -> DerivedValue
  ) -> Shared<DerivedArray<Value.ID, DerivedValue>> where DerivedValue.ID == Value.ID {
    self.deriveMap(id: \.id, fn)
  }

  public func deriveMap<DerivedValue>(
    id: KeyPath<DerivedValue, Value.ID>,
    _ fn: @Sendable @escaping (SharedReader<Value.Element>) -> DerivedValue
  ) -> Shared<DerivedArray<Value.ID, DerivedValue>> {
    self.deriveMap(initialValues: DerivedArray(id: id), fn)
  }

  public func deriveMap<DerivedValue>(
    initialValues: DerivedArray<Value.ID, DerivedValue>,
    _ fn: @Sendable @escaping (SharedReader<Value.Element>) -> DerivedValue
  ) -> Shared<DerivedArray<Value.ID, DerivedValue>> {
    Shared(
      wrappedValue: initialValues,
      DerivedKey(initialValues: initialValues, reader: self, derive: fn)
    )
  }
}

// MARK: - DerivedArray

public struct DerivedArray<ID: Hashable & Sendable, Element: Sendable>: Sendable {
  package var identifiedArray: IdentifiedArray<ID, Element>

  fileprivate init(id: KeyPath<Element, ID>) {
    self.identifiedArray = IdentifiedArray(id: id)
  }
}

extension DerivedArray: Collection {
  public typealias Index = Int

  public var startIndex: Index { self.identifiedArray.startIndex }

  public var endIndex: Index { self.identifiedArray.endIndex }

  public subscript(position: Index) -> Element {
    _read { yield self.identifiedArray[position] }
    _modify { yield &self.identifiedArray[position] }
  }

  public func index(after i: Index) -> Index {
    self.identifiedArray.index(after: i)
  }
}

extension DerivedArray {
  public subscript(id identifier: ID) -> Element? {
    _read { yield self.identifiedArray[id: identifier] }
    _modify { yield &self.identifiedArray[id: identifier] }
  }
}

extension DerivedArray {
  fileprivate mutating func sync<S: _Shareable>(
    elements: S,
    mapper: (SharedReader<S.Value.Element>) -> Element
  ) where S.Value: _IdentifiedCollection, S.Value.ID == ID {
    var copy = self.identifiedArray
    copy.removeAll()
    for id in elements.wrappedValue.ids {
      guard let reader = SharedReader(elements[dynamicMember: \.[id: id]]) else { continue }
      copy[id: id] = self.identifiedArray[id: id] ?? mapper(reader)
    }
    self.identifiedArray = copy
  }
}

extension DerivedArray: Equatable where Element: Equatable {}
extension DerivedArray: Hashable where Element: Hashable {}

// MARK: - DerivedKey

private struct DerivedKey<
  DerivedValue: Sendable,
  S: _Shareable
>: Sendable where S.Value: _IdentifiedCollection, S.Value.ID: Sendable {
  private let reader: S
  private let derive: @Sendable (SharedReader<S.Value.Element>) -> DerivedValue
  private let box: Box<S.Value.ID, DerivedValue>
  let id = DerivedKeyID()

  fileprivate init(
    initialValues: DerivedArray<S.Value.ID, DerivedValue>,
    reader: S,
    derive: @escaping @Sendable (SharedReader<S.Value.Element>) -> DerivedValue
  ) {
    self.box = Box(initialValues: initialValues)
    self.reader = reader
    self.derive = derive
  }
}

extension DerivedKey: SharedKey {
  typealias Value = DerivedArray<S.Value.ID, DerivedValue>

  func save(_ value: Value, context: SaveContext, continuation: SaveContinuation) {
    self.box.setArray(value)
    continuation.resume()
  }

  func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
    continuation.resumeReturningInitialValue()
  }

  func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    let token = self.reader.observe { _ in
      self.box.withLock {
        $0.sync(elements: reader, mapper: self.derive)
        subscriber.yield($0)
      }
    }
    return SharedSubscription { token.cancel() }
  }
}

// MARK: - DerivedKeyID

private struct DerivedKeyID: Hashable {
  private let uuid = UUID()
}

// MARK: - Box

private final class Box<ID: Hashable & Sendable, Element: Sendable>: Sendable {
  private let array: Lock<DerivedArray<ID, Element>>

  init(initialValues array: DerivedArray<ID, Element>) {
    self.array = Lock(array)
  }

  func setArray(_ array: DerivedArray<ID, Element>) {
    self.withLock {
      let current = $0
      $0 = array
      if current.identifiedArray.ids != $0.identifiedArray.ids {
        reportIssue(
          """
          A new derived array has been assigned directly to an @Shared value that is structurally \
          different from the current value.

          Avoid assigning a completely different instance of DerivedArray to an @Shared instance \
          that was constructed through calling deriveMap on another @Shared or @SharedReader \
          instance. Instead, mutate the individual elements of the DerivedArray if you want to \
          make changes to the array.

          The derived array needs to have the same number of elements, and the same id order as its \
          base shared array to ensure that it reflects a purely derived state of its current \
          values. When the base shared array updates again, the order of this derived array will \
          reflect the order of the base shared array.
          """
        )
      }
    }
  }

  func withLock(_ fn: @Sendable (inout DerivedArray<ID, Element>) -> Void) {
    self.array.withLock { fn(&$0) }
  }
}
