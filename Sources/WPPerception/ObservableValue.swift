// MARK: - ObservableValue

/// A protocol to mark a value type as observable to be used in conjunction with ``ObservedValue``.
public protocol ObservableValue {}

// MARK: - Box

struct Box {
  fileprivate let value: Any
}

extension ObservableValue {
  subscript<Value>(keyPath: WritableKeyPath<Self, Value>) -> Box {
    get { Box(value: self[keyPath: keyPath]) }
    set { self[keyPath: keyPath] = newValue.value as! Value }
  }
}
