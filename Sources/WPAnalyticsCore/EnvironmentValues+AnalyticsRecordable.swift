import SwiftUI

extension EnvironmentValues {
  /// The current ``AnalyticsRecordable`` to record analytic events in this environment.
  @Entry public var analyticsRecordable: any AnalyticsRecordable & Sendable =
    ConsoleAnalyticsRecorder()
}
