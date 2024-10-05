import Perception

// MARK: - ObservedValue

@Perceptible
@dynamicMemberLookup
public final class ObservedValue<Value: ObservableValue> {
  private let willSet: ((Value, Value) -> Void)?
  private let didSet: ((Value, Value) -> Void)?
  
  @PerceptionIgnored private var _value: Value {
    willSet { self.willSet?(newValue, self._value) }
    didSet { self.didSet?(oldValue, self._value) }
  }
  
  @PerceptionIgnored private var observedPaths = Set<WritableKeyPath<Value, Box>>()
  
  public init(
    _ value: Value,
    willSet: ((_ newValue: Value, _ oldValue: Value) -> Void)? = nil,
    didSet: ((_ oldValue: Value, _ newValue: Value) -> Void)? = nil
  ) {
    self._value = value
    self.willSet = willSet
    self.didSet = didSet
  }
}

// MARK: - Value

extension ObservedValue {
  public var value: Value {
    get {
      self.access(keyPath: \.value)
      return self._value
    }
    set {
      self.withMutation(keyPath: \.value) {
        for path in self.observedPaths {
          self.withMutation(keyPath: self.modelKeyPath(for: path)) {
            self._value[keyPath: path] = newValue[keyPath: path]
          }
        }
        self._value = newValue
      }
    }
    _modify {
      for path in self.observedPaths {
        self._$perceptionRegistrar.willSet(self, keyPath: self.modelKeyPath(for: path))
      }
      self._$perceptionRegistrar.willSet(self, keyPath: \.value)
      defer {
        for path in self.observedPaths {
          self._$perceptionRegistrar.didSet(self, keyPath: self.modelKeyPath(for: path))
        }
        self._$perceptionRegistrar.didSet(self, keyPath: \.value)
      }
      yield &self._value
    }
  }
}

// MARK: - Dynamic Member Lookup

extension ObservedValue {
  public subscript<R>(dynamicMember keyPath: WritableKeyPath<Value, R>) -> R {
    get {
      self.access(keyPath: self.modelKeyPath(for: keyPath))
      return self._value[keyPath: keyPath]
    }
    set {
      self.withMutation(keyPath: self.modelKeyPath(for: keyPath)) {
        self.withMutation(keyPath: \.value) {
          self._value[keyPath: keyPath] = newValue
        }
      }
    }
  }
}

// MARK: - ModelKeyPath

extension ObservedValue {
  private func modelKeyPath<R>(
    for keyPath: WritableKeyPath<Value, R>
  ) -> KeyPath<ObservedValue<Value>, Box> {
    self.modelKeyPath(for: \.[keyPath])
  }
  
  private func modelKeyPath(
    for keyPath: WritableKeyPath<Value, Box>
  ) -> KeyPath<ObservedValue<Value>, Box> {
    self.observedPaths.insert(keyPath)
    return (\ObservedValue<Value>._value).appending(path: keyPath)
  }
}
