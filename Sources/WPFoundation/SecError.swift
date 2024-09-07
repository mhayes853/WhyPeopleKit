import Security
import Foundation

// MARK: - SecError

/// An error type for error codes returned from the Security framework.
public struct SecError: Error, Hashable, Sendable {
  public let code: OSStatus
  
  public init(code: OSStatus) {
    self.code = code
  }
}

// MARK: - Message

extension SecError {
  /// A human readable error message string from this error.
  public var message: String {
    SecCopyErrorMessageString(self.code, nil) as? String ?? "Unknown Security Framework Error"
  }
}
