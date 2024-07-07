public enum OptInStatus: Hashable, Sendable {
  case `in`, out
}

extension OptInStatus {
  public var isOptedIn: Bool {
    self == .in
  }
}
