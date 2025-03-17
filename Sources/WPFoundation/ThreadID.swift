import Foundation

/// A data type representing the id of a thread.
public struct ThreadID: Hashable, Sendable {
  /// The raw integer thread id.
  public let rawValue: UInt64
}

extension ThreadID {
  /// The current thread id.
  public static var current: Self {
    #if os(Linux)
      return Self(rawValue: UInt64(pthread_self()))
    #else
      var id = UInt64(0)
      pthread_threadid_np(nil, &id)
      return Self(rawValue: id)
    #endif
  }
}
