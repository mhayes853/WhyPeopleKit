import Perception

@Perceptible
@dynamicMemberLookup
public final class ObservedValue<Value: ObservableValue> {
  @PerceptionIgnored private var _value: Value
  @PerceptionIgnored private var observedPaths = Set<WritableKeyPath<Value, Box>>()
  
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
  
  public init(_ value: Value) {
    self._value = value
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
