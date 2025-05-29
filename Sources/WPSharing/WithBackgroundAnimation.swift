#if canImport(SwiftUI)
  import SwiftUI
  import IssueReporting

  public func withBackgroundAnimation(
    _ animation: Animation?,
    _ body: @escaping @Sendable () -> Void
  ) {
    if let animation, !isTesting {
      Task { @MainActor in
        withAnimation(animation) {
          body()
        }
      }
    } else {
      body()
    }
  }
#endif
