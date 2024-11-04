import IssueReporting

public typealias TestID = TestContext.Testing.Test.ID

extension TestID {
  /// The current ``TestID`` if running within a non-detached task of a swift-testing test.
  public static var current: Self? {
    switch TestContext.current {
    case let .swiftTesting(testing): testing?.test.id
    default: nil
    }
  }
}
