import WPFoundation
import Testing
import XCTest

// MARK: - _DefaultTestFailable

// NB: This internal class is called by WPFoundation using NSClassFromString to decide what test
// framework to use when calling failCurrentTest. WPFoundation cannot use this class directly
// since we import both XCTest and Swift Testing in this test support module.
@objc(_WPDefaultTestFailable)
final class _DefaultTestFailable: NSObject, DefaultTestFailable {
  // NB: Using "new" gives a warning when using a string Selector, but applying the fix-it from
  // that warning results in a compile error, so we'll need this method to use for the selector.
  @objc class func current() -> _DefaultTestFailable { _DefaultTestFailable() }
  
  private var failable: any TestFailable {
    if Test.current != nil {
      SwiftTestingFailable()
    } else {
      XCTestFailable()
    }
  }
  
  public func failTest(_ message: String?, file: StaticString, line: UInt) {
    self.failable.failTest(message, file: file, line: line)
  }
}
