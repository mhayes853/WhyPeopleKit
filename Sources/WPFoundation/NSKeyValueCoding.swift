import Foundation

/// A formal protocol for `NSKeyValueCoding` on `NSObject`s.
public protocol NSKeyValueCoding: NSObject {
  func value(forKey key: String) -> Any?
  func setValue(_ value: Any?, forKey key: String)
}

extension UserDefaults: NSKeyValueCoding {}
extension NSUbiquitousKeyValueStore: NSKeyValueCoding {}
