import Testing
import WPFoundation

/// A `TestFailable` conformance that uses swift testing.
public struct SwiftTestingFailable: TestFailable, Sendable {
  public init() {}
  
  public func failTest(_ message: String?, file: StaticString, line: UInt) {
    Issue.record(
      message.map(Comment.init(rawValue:)),
      fileID: String(describing: file),
      line: Int(line)
    )
  }
}
