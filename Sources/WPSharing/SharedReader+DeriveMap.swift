import IdentifiedCollections
import Perception
import WPDependencies
import WPFoundation
import WPSwiftNavigation

// MARK: - Map

extension SharedReader {
  public func deriveMap<ID: Hashable, Element: Sendable, DerivedValue>(
    id: KeyPath<DerivedValue, ID>,
    _ fn: @Sendable @escaping (SharedReader<Value.Element>) -> DerivedValue
  ) -> Shared<DerivedArray<Value.ID, DerivedValue>> where Value == IdentifiedArray<ID, Element> {
    Shared(
      wrappedValue: DerivedArray(id: id),
      DerivedKey(
        idPath: unsafeBitCast(id, to: (KeyPath<DerivedValue, ID> & Sendable).self),
        reader: self,
        derive: fn
      )
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
  fileprivate mutating func sync<BaseElement>(
    elements: SharedReader<IdentifiedArray<ID, BaseElement>>,
    mapper: (SharedReader<BaseElement>) -> Element
  ) {
    var copy = self._identifiedArray
    copy.removeAll()
    for id in elements.wrappedValue.ids {
      guard let reader = SharedReader(elements[id: id]) else { continue }
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
  ID: Hashable & Sendable,
  Element
>: Sendable {
  private let reader: SharedReader<IdentifiedArray<ID, Element>>
  private let derive: @Sendable (SharedReader<Element>) -> DerivedValue
  private let box: Box<ID, DerivedValue>
  let id = DerivedKeyID()

  fileprivate init(
    idPath: KeyPath<DerivedValue, ID> & Sendable,
    reader: SharedReader<IdentifiedArray<ID, Element>>,
    derive: @escaping @Sendable (SharedReader<Element>) -> DerivedValue
  ) {
    self.box = Box(idPath: idPath)
    self.reader = reader
    self.derive = derive
  }
}

extension DerivedKey: SharedKey {
  typealias Value = DerivedArray<ID, DerivedValue>

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

  init(idPath: KeyPath<Element, ID>) {
    self.array = Lock(DerivedArray(id: idPath))
  }

  func withLock(_ fn: @Sendable (inout DerivedArray<ID, Element>) -> Void) {
    self.array.withLock { fn(&$0) }
  }
}
