import IdentifiedCollections
import Perception
import WPDependencies
import WPFoundation
import WPSwiftNavigation

// MARK: - Map

extension _Shareable where Value: _IdentifiedCollection, Value.ID: Sendable {
  public func deriveMap<DerivedValue>(
    id: KeyPath<DerivedValue, Value.ID>,
    _ fn: @Sendable @escaping (SharedReader<Value.Element>) -> DerivedValue
  ) -> Shared<DerivedArray<Value.ID, DerivedValue>> {
    let idPath = unsafeBitCast(id, to: (KeyPath<DerivedValue, Value.ID> & Sendable).self)
    return self.deriveMap(initialValues: DerivedArray(id: idPath), fn)
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
  private var _identifiedArray: IdentifiedArray<ID, Element>
}

extension DerivedArray {
  public var identifiedArray: IdentifiedArray<ID, Element> {
    get { self._identifiedArray }
    set {
      precondition(
        self._identifiedArray.ids == newValue.ids,
        """
        Identified array elements and positions must remain the same in order to remain \
        consistent with the derived collection.
        """
      )
      self._identifiedArray = newValue
    }
  }
}

extension DerivedArray {
  public init(id: KeyPath<Element, ID>) {
    self._identifiedArray = IdentifiedArray(id: id)
  }

  public init() where Element: Identifiable, ID == Element.ID {
    self._identifiedArray = IdentifiedArrayOf()
  }
}

extension DerivedArray {
  fileprivate mutating func sync<S: _Shareable>(
    elements: S,
    mapper: (SharedReader<S.Value.Element>) -> Element
  ) where S.Value: _IdentifiedCollection, S.Value.ID == ID {
    var copy = self._identifiedArray
    copy.removeAll()
    for id in elements.wrappedValue.ids {
      guard let reader = SharedReader(elements[dynamicMember: \.[id: id]]) else { continue }
      copy[id: id] = self._identifiedArray[id: id] ?? mapper(reader)
    }
    self._identifiedArray = copy
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
    self.box.withLock { $0 = value }
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

  func withLock(_ fn: @Sendable (inout DerivedArray<ID, Element>) -> Void) {
    self.array.withLock { fn(&$0) }
  }
}
