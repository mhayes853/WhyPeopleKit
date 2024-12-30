// MARK: - EquatableObject

public protocol EquatableObject: Equatable, AnyObject {}

extension EquatableObject {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs === rhs
  }
}

// MARK: - HashableObject

public protocol HashableObject: EquatableObject, Hashable {}

extension HashableObject {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
