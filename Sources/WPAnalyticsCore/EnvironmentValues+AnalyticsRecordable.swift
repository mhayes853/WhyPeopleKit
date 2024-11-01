#if canImport(SwiftUI)
  import SwiftUI

  extension EnvironmentValues {
    /// The current ``AnalyticsRecordable`` to record analytic events in this environment.
    @Entry public var analytics: any AnalyticsRecordable & Sendable = ConsoleAnalyticsRecorder()
  }
#endif
