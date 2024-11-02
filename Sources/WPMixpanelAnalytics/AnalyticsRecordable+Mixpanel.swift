#if canImport(Mixpanel)
  @preconcurrency import Mixpanel
  import WPAnalyticsCore

  // MARK: - MixpanelAnalyticsRecorder

  /// An `AnalyticsRecordable` using a `MixpanelInstance`.
  public struct MixpanelAnalyticsRecorder: AnalyticsRecordable, Sendable {
    private let instance: MixpanelInstance

    public init(_ instance: MixpanelInstance) {
      self.instance = instance
    }

    public func record(event: AnalyticsEvent) {
      switch event {
      case let .event(name, properties):
        self.instance.track(event: name, properties: properties.mixpanelProperties)

      case let .identify(userId):
        self.instance.identify(distinctId: userId)

      case let .setUserProperties(properties):
        self.instance.people.set(properties: properties.mixpanelProperties)

      case .opt(.in):
        self.instance.optInTracking()

      case .opt(.out):
        self.instance.optOutTracking()

      case let .custom(event):
        (event as? any CustomMixpanelEvent)?.record(on: self.instance)
      }
    }
  }

  // MARK: - AnalyticsRecordable Extensions

  extension AnalyticsRecordable where Self == MixpanelAnalyticsRecorder {
    /// Creates an `AnalyticsRecordable` using the specified `MixpanelInstance`.
    ///
    /// - Parameter instance: The `MixpanelInstance` to use.
    /// - Returns: `AnalyticsRecordable` using `instance`.
    public static func mixpanel(_ instance: MixpanelInstance) -> Self {
      MixpanelAnalyticsRecorder(instance)
    }

    /// An `AnalyticsRecordable` using `Mixpanel.mainInstance()`.
    public static var mixpanel: Self {
      .mixpanel(Mixpanel.mainInstance())
    }
  }
#endif
