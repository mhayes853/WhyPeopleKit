import Mixpanel
import WPAnalyticsCore

// MARK: - CustomMixpanelEvent

/// A protocol for a custom `AnalyticsEvent` that uses Mixpanel.
///
/// This protocol is useful for modularizing application-specific custom analytics events across
/// multiple modules. For instance, we may have an application-specific event set a user group.
/// We'll start by defining a custom `SetUserGroupEvent` in a module that cannot import
/// ``WPMixpanelAnalytics``.
///
/// ```swift
/// // In Module A (Cannot import WPMixpanelAnalytics)
/// import WPAnalyticsCore
///
/// public struct SetUserGroupEvent: Equatable, Sendable {
///   public let type: String
///   public let id: String
///   public let properties: [String: AnalyticsEvent.Value?]
/// }
///
/// extension AnaltyticsEvent {
///   public static func setUserGroup(
///     type: Double,
///     id: String,
///     properties: [String: AnalyticsEvent.Value?]
///   ) -> Self {
///     .custom(SetUserGroupEvent(type: type, id: id, properties: properties))
///   }
/// }
/// ```
///
/// We can then conform `SetUserGroupEvent` to ``CustomMixpanelEvent`` in another module that can import
/// ``WPMixpanelAnalytics``.
///
/// ```swift
/// // In Module B (Can import WPMixpanelAnalytics)
/// import ModuleA
/// import WPMixpanelAnalytics
///
/// extension SetUserGroupEvent: CustomMixpanelEvent {
///   public func record(on instance: MixpanelInstance) {
///     instance.setGroup(groupKey: self.type, groupID: self.id)
///     instance.getGroup(groupKey: self.type, groupID: self.id)
///       .set(properties: self.properties.mixpanelProperties)
///   }
/// }
/// ```
///
/// Anytime we record `.setUserGroup` on the `AnalyticsRecordable` instance provided by
/// ``WPMixpanelAnalytics``, the current user will be added to the user group on Mixpanel.
public protocol CustomMixpanelEvent: Equatable, Sendable {
  /// Records this event on a `MixpanelInstance`.
  ///
  /// - Parameter instance: A `MixpanelInstance`.
  func record(on instance: MixpanelInstance)
}

// MARK: - Extension

extension AnalyticsEvent {
  /// Returns a custom `AnalyticsEvent` using a ``CustomMixpanelEvent``.
  ///
  /// - Parameter event: A ``CustomMixpanelEvent``.
  /// - Returns: A custom `AnalyticsEvent`.
  public static func mixpanel(_ event: some CustomMixpanelEvent) -> Self {
    .custom(event)
  }
}

