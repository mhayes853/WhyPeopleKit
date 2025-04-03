import Foundation

/// A protocol to aid in writing shared abstractions between `UserDefaults` and
/// `NSUbiquitousKeyValueStore`.
public protocol DefaultsKeyValueStore: NSObject {
  func object(forKey key: String) -> Any?
  func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: DefaultsKeyValueStore {}

#if !os(Linux)
  @available(watchOS 9.0, *)
  extension NSUbiquitousKeyValueStore: DefaultsKeyValueStore {}
#endif
