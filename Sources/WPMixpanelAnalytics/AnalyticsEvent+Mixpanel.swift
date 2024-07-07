import Mixpanel
import WPAnalyticsCore

// MARK: - CustomMixpanelEvent

/// A protocol for a custom `AnalyticsEvent` that uses Mixpanel.
///
/// This protocol is useful for modularizing application-specific custom analytics events across
/// multiple modules. For instance, we may have an application-specific event to track a charge.
/// We'll start by defining a custom `TrackChargeEvent` in a module that cannot import
/// ``WPMixpanelAnalytics``.
///
/// ```swift
/// // In Module A (Cannot import WPMixpanelAnalytics)
/// import WPAnalyticsCore
///
/// public struct TrackChargeEvent: Equatable, Sendable {
///   public let amount: Double
///   public let properties: [String: AnalyticsEvent.Value?]
/// }
///
/// extension AnaltyticsEvent {
///   public static func trackCharge(
///     amount: Double,
///     properties: [String: AnalyticsEvent.Value?]
///   ) -> Self {
///     .custom(TrackChargeEvent(amount: amount, properties: properties))
///   }
/// }
/// ```
///
/// We can then conform `TrackChargeEvent` to ``CustomMixpanelEvent`` in another module that can import
/// ``WPMixpanelAnalytics``.
///
/// ```swift
/// // In Module B (Can import WPMixpanelAnalytics)
/// import ModuleA
/// import WPMixpanelAnalytics
///
/// extension TrackChargeEvent: CustomMixpanelEvent {
///   public func record(on instance: MixpanelInstance) {
///     instance.people.trackCharge(
///       amount: self.amount,
///       properties: self.properties.mixpanelProperties
///     )
///   }
/// }
/// ```
///
/// Anytime we record `.trackCharges` on the `AnalyticsRecordable` instance provided by
/// ``WPMixpanelAnalytics``, a charge will be tracked to Mixpanel.
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

