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
      
    case let .opt(status):
      switch status {
      case .in: self.instance.optInTracking()
      case .out: self.instance.optOutTracking()
      }
      
    case let .custom(event):
      (event as? any CustomMixpanelEvent)?.record(on: self.instance)
    }
  }
}

// MARK: - Main Instance

extension MixpanelAnalyticsRecorder {
  public static let main = Self(Mixpanel.mainInstance())
}

// MARK: - AnalyticsRecordable Extensions

extension AnalyticsRecordable where Self == MixpanelAnalyticsRecorder {
  public static func mixpanel(_ instance: MixpanelInstance) -> Self {
    MixpanelAnalyticsRecorder(instance)
  }
  
  public static var mixpanel: Self {
    .main
  }
}
