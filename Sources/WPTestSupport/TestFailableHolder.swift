import WPFoundation
import Testing
import XCTest

// MARK: - TestFailableHolder

// NB: This internal class is called by WPFoundation using NSClassFromString to decide what test
// framework to use when calling failCurrentTest. WPFoundation cannot use this class directly
// since we import both XCTest and Swift Testing.
@objc(TestFailableHolder)
final class TestFailableHolder: NSObject, @unchecked Sendable {
  @objc let failable: Any
  
  private init(failable: any TestFailable & Sendable) {
    self.failable = failable
  }
}

// MARK: - Current

extension TestFailableHolder {
  @objc class func current() -> TestFailableHolder {
    if Test.current != nil {
      TestFailableHolder(failable: SwiftTestingFailable())
    } else {
      TestFailableHolder(failable: XCTestFailable())
    }
  }
}
