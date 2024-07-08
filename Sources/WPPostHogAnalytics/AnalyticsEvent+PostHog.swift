import PostHog
import WPAnalyticsCore

// MARK: - CustomPostHogEvent

/// A protocol for a custom `AnalyticsEvent` that uses PostHog.
///
/// This protocol is useful for modularizing application-specific custom analytics events across
/// multiple modules. For instance, we may have an application-specific event to set a user group.
/// We'll start by defining a custom `SetUserGroupEvent` in a module that cannot import
/// ``WPPostHogAnalytics``.
///
/// ```swift
/// // In Module A (Cannot import WPPostHogAnalytics)
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
///     type: String,
///     id: String,
///     properties: [String: AnalyticsEvent.Value?] = [:]
///   ) -> Self {
///     .custom(SetUserGroupEvent(type: type, id: id, properties: properties))
///   }
/// }
/// ```
///
/// We can then conform `SetUserGroupEvent` to ``CustomPostHogEvent`` in another module that can import
/// ``WPPostHogAnalytics``.
///
/// ```swift
/// // In Module B (Can import WPPostHogAnalytics)
/// import ModuleA
/// import WPPostHogAnalytics
///
/// extension SetUserGroupEvent: CustomPostHogEvent {
///   public func record(on sdk: PostHogSDK) {
///     sdk.group(type: self.type, key: self.id, properties: self.properties.postHogProperties)
///   }
/// }
/// ```
///
/// Anytime we record `.setUserGroup` on the `AnalyticsRecordable` instance provided by
/// ``WPPostHogAnalytics``, the current user will be added to the user group on PostHog.
public protocol CustomPostHogEvent: Equatable, Sendable {
  /// Records this event on the `PostHogSDK`.
  ///
  /// - Parameter sdk: `PostHogSDK.shared`.
  func record(on sdk: PostHogSDK)
}

// MARK: - AnalyticsEvent Extension

extension AnalyticsEvent {
  /// Returns a custom `AnalyticsEvent` using a ``CustomPostHogEvent``.
  ///
  /// - Parameter event: A ``CustomPostHogEvent``.
  /// - Returns: A custom `AnalyticsEvent`.
  public static func postHog(_ event: some CustomPostHogEvent) -> Self {
    .custom(event)
  }
}
