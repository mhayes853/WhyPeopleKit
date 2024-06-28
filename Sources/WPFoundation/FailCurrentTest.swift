#if canImport(XCTest)
import XCTest
#endif

#if canImport(Testing)
import Testing
#endif

/// Fails the current test case regardless of whether XCTest or Swift Testing is used.
public func failCurrentTest(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) {
#if canImport(Testing) && canImport(XCTest)
  if Test.current != nil {
    Issue.record(Comment(rawValue: message), filePath: String(describing: file), line: Int(line))
  } else {
    XCTFail(message)
  }
#elseif canImport(Testing)
  if Test.current != nil {
    Issue.record(Comment(rawValue: message), filePath: String(describing: file), line: Int(line))
  }
#elseif canImport(XCTest)
  XCTFail(message)
#endif
}
