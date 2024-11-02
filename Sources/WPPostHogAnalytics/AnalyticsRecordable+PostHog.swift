#if canImport(PostHog)
  import PostHog
  import WPAnalyticsCore

  // MARK: - PostHogAnalyticsRecorder

  /// An `AnalyticsRecordable` that uses the PostHog SDK.
  public struct PostHogAnalyticsRecorder: AnalyticsRecordable, Sendable {
    public init() {}

    public func record(event: AnalyticsEvent) {
      switch event {
      case let .event(name, properties):
        PostHogSDK.shared.capture(name, properties: properties.postHogProperties)

      case let .identify(distinctId):
        PostHogSDK.shared.identify(distinctId)

      case .opt(.in):
        PostHogSDK.shared.optIn()

      case .opt(.out):
        PostHogSDK.shared.optOut()

      case let .setUserProperties(properties):
        PostHogSDK.shared.capture("$set", properties: ["$set": properties.postHogProperties])

      case let .custom(event):
        (event as? any CustomPostHogEvent)?.record(on: .shared)
      }
    }
  }

  // MARK: - AnalyticsRecordable Extension

  extension AnalyticsRecordable where Self == PostHogAnalyticsRecorder {
    /// An `AnalyticsRecordable` that uses the PostHog SDK.
    public static var postHog: Self {
      PostHogAnalyticsRecorder()
    }
  }
#endif
