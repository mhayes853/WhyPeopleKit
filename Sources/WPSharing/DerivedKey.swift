import IdentifiedCollections
import Perception
import WPDependencies
import WPFoundation

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
      copy[id: id] = self._identifiedArray[id: id] ?? mapper(SharedReader(elements[id: id])!)
    }
    self._identifiedArray = copy
  }
}

extension DerivedArray: Equatable where Element: Equatable {}
extension DerivedArray: Hashable where Element: Hashable {}

public struct DerivedKey<
  DerivedValue: Sendable,
  BaseKey: SharedReaderKey,
  ID: Hashable & Sendable,
  Element
>: Sendable where BaseKey.Value == IdentifiedArray<ID, Element> {
  private let baseKey: BaseKey
  private let key: String
  private let storage: DerivedStorage
  private let derive: @Sendable (SharedReader<Element>) -> DerivedValue

  fileprivate init(
    baseKey: BaseKey,
    key: String,
    derive: @escaping @Sendable (SharedReader<Element>) -> DerivedValue
  ) {
    @Dependency(\.defaultDerivedStorage) var storage
    self.baseKey = baseKey
    self.key = key
    self.derive = derive
    self.storage = storage
  }
}

extension DerivedKey: SharedKey {
  public typealias Value = DerivedArray<ID, DerivedValue>

  public var id: DerivedKeyID {
    DerivedKeyID(baseKey: self.baseKey, key: self.key, storage: self.storage)
  }

  public func save(_ value: Value, immediately: Bool) {
    self.storage.values[self.storageKey] = value
  }

  public func load(initialValue: Value?) -> Value? {
    self.storage.values[self.storageKey, default: initialValue] as? Value
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (Value?) -> Void
  ) -> SharedSubscription {
    let isCancelled = Lock(false)
    let isPublished = Lock(false)
    var subscription: SharedSubscription?
    var _subscription: SharedSubscription? { subscription }
    subscription = self.baseKey.subscribe(initialValue: nil) { value in
      guard let value else { return }
      let shouldLeave = isPublished.withLock { i in
        defer { i = true }
        return i
      }
      guard !shouldLeave else { return }

      // NB: We need to use the shared reader value directly instead of relying on the subscription
      // because the reader ensures that the shared values we pass to the derived state are
      // connected to the parent.
      let reader = SharedReader(wrappedValue: value, self.baseKey)
      @Sendable
      func observe() {
        withPerceptionTracking {
          guard isCancelled.withLock({ !$0 }) else { return }
          guard var array = self.load(initialValue: initialValue) else { return }
          array.sync(elements: reader, mapper: self.derive)
          self.save(array, immediately: false)
          receiveValue(array)
        } onChange: {
          guard isCancelled.withLock({ !$0 }) else { return }
          observe()
        }
      }
      observe()
    }
    return SharedSubscription {
      _subscription?.cancel()
      isCancelled.withLock { $0 = true }
    }
  }

  private var storageKey: DerivedStorageKey {
    DerivedStorageKey(baseKey: self.baseKey, key: self.key)
  }
}

// MARK: - DerivedKeyID

public struct DerivedKeyID: Hashable {
  private let baseKey: AnyHashable
  private let key: String
  private let storage: DerivedStorage

  fileprivate init(baseKey: some SharedReaderKey, key: String, storage: DerivedStorage) {
    self.baseKey = baseKey.id
    self.key = key
    self.storage = storage
  }
}

extension DerivedKey {
  public static func derived(
    _ base: BaseKey,
    _ key: String,
    derive: @Sendable @escaping (SharedReader<Element>) -> DerivedValue
  ) -> DerivedKey<DerivedValue, BaseKey, ID, Element>
  where BaseKey.Value == IdentifiedArray<ID, Element> {
    Self(baseKey: base, key: key, derive: derive)
  }
}

extension DerivedKey where Element: Identifiable, ID == Element.ID {
  public static func derived(
    _ base: BaseKey,
    _ key: String,
    derive: @Sendable @escaping (SharedReader<Element>) -> DerivedValue
  ) -> DerivedKey<DerivedValue, BaseKey, Element.ID, Element>
  where BaseKey.Value == IdentifiedArrayOf<Element> {
    Self(baseKey: base, key: key, derive: derive)
  }
}

public typealias DerivedKeyOf<
  DerivedValue: Sendable,
  BaseKey: SharedReaderKey,
  Element: Identifiable
> = DerivedKey<DerivedValue, BaseKey, Element.ID, Element>
where BaseKey.Value == IdentifiedArrayOf<Element>

// MARK: - DerivedStorage

public struct DerivedStorage: Hashable, Sendable {
  private let id = UUID()
  fileprivate let values = Values()
  public init() {}
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  typealias Entry = any Sendable

  fileprivate final class Values: Sendable {
    let storage = Lock<[DerivedStorageKey: Entry]>([:])

    subscript(key: DerivedStorageKey) -> Entry? {
      get { storage.withLock { $0[key] } }
      set { storage.withLock { $0[key] = newValue } }
    }

    subscript(key: DerivedStorageKey, default defaultValue: Entry?) -> Entry? {
      storage.withLock {
        $0[key] = $0[key] ?? defaultValue
        return $0[key]
      }
    }
  }
}

// MARK: - Default Derived Storage Dependency

extension DependencyValues {
  public var defaultDerivedStorage: DerivedStorage {
    get { self[DefaultDerivedStorageKey.self] }
    set { self[DefaultDerivedStorageKey.self] = newValue }
  }
}

private enum DefaultDerivedStorageKey: DependencyKey {
  static var liveValue: DerivedStorage { DerivedStorage() }
  static var testValue: DerivedStorage { DerivedStorage() }
}

// MARK: - DerivedStorageKey

private struct DerivedStorageKey: Hashable, Sendable {
  private let baseKeyHash: Int
  private let key: String

  init(baseKey: some SharedReaderKey, key: String) {
    self.baseKeyHash = baseKey.id.hashValue
    self.key = key
  }
}
