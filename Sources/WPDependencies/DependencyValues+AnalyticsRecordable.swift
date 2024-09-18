import WPAnalyticsCore

extension DependencyValues {
  /// The current `AnalyticsRecordable` that features should use to record analytic events.
  ///
  /// By default, `ConsoleAnalyticsRecordable` is supplied. You can override this value with a
  /// custom `AnalyticsRecordable`, or by using the Mixpanel or Posthog conformances in this
  /// swift package.
  ///
  /// ```swift
  /// let model = withDependencies {
  ///   $0.analyticsRecordable = .mixpanel
  ///   // OR
  ///   $0.analyticsRecordable = .postHog
  /// } operation: {
  ///   FeatureModel()
  /// }
  /// ```
  ///
  /// In test contexts you can provide an instance using `TestAnalyticsRecorder` to inspect the
  /// recorded events.
  ///
  /// ```swift
  /// let recorder = TestAnalyticsRecorder()
  ///
  /// // Provision model with overridden dependencies
  /// let model = withDependencies {
  ///   $0.analyticsRecordable = recorder
  /// } operation: {
  ///   FeatureModel()
  /// }
  ///
  /// // Make assertions with model, and inspect recorded events...
  /// #expect(recorder.recordedEvents == [/* ... */])
  /// ```
  public var analyticsRecordable: any AnalyticsRecordable & Sendable {
    get { self[AnalyticsRecordableKey.self] }
    set { self[AnalyticsRecordableKey.self] = newValue }
  }

  private struct AnalyticsRecordableKey: DependencyKey {
    static var liveValue: any AnalyticsRecordable & Sendable {
      ConsoleAnalyticsRecorder()
    }

    static var testValue: any AnalyticsRecordable & Sendable {
      FailingAnalyticsRecorder()
    }
  }
}
