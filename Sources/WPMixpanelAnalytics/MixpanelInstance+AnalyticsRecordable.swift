import Mixpanel
import WPAnalyticsCore

extension MixpanelInstance: @retroactive AnalyticsRecordable {
  public func record(event: AnalyticsEvent) {
    switch event {
    case let .event(name, properties):
      self.track(event: name, properties: properties.mixpanelProperties)
      
    case let .identify(userId):
      self.identify(distinctId: userId)
      
    case let .setUserProperties(properties):
      self.people.set(properties: properties.mixpanelProperties)
      
    case let .opt(status):
      switch status {
      case .in: self.optInTracking()
      case .out: self.optOutTracking()
      }
      
    case let .custom(event):
      (event as? @Sendable (MixpanelInstance) -> Void)?(self)
    }
  }
}

