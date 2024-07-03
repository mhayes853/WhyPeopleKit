import XCTest
import WPFoundation

/// A `TestFailable` conformance that uses XCTest.
public struct XCTestFailable: TestFailable, Sendable {
  public init() {}
  
  public func failTest(_ message: String?, file: StaticString, line: UInt) {
    if let message {
      XCTFail(message, file: file, line: line)
    } else {
      XCTFail(file: file, line: line)
    }
  }
}
