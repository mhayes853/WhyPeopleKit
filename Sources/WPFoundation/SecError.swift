import Security
import Foundation

/// An error type for error codes returned from the Security framework.
public struct SecError: Error {
  public let code: OSStatus
  
  public init(code: OSStatus) {
    self.code = code
  }
}
