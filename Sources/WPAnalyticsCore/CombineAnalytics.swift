// MARK: - Variadic Combine

/// Combines multiple specified analytics recorders into a single recorder.
///
/// ```swift
/// let analytics = combineAnalytics(.postHog, .console, TestAnalyticsRecorder())
/// ```
///
/// - Parameter recorder: A variadic list of ``AnalyticsRecordable``.
/// - Returns: A ``VariadicCombinedAnalyticsRecorder``.
@inlinable
@available(iOS 17, macOS 14, watchOS 9, tvOS 17, *)
public func combineAnalytics<each R: AnalyticsRecordable & Sendable>(
  _ recorder: repeat each R
) -> VariadicCombinedAnalyticsRecorder<repeat each R> {
  VariadicCombinedAnalyticsRecorder(recorder: (repeat each recorder))
}

/// An ``AnalyticsRecordable`` type that combines a variadic list of analytics recorders.
///
/// You create this type by calling ``combineAnalytics(_:)``.
@available(iOS 17, macOS 14, watchOS 9, tvOS 17, *)
public struct VariadicCombinedAnalyticsRecorder<
  each R: AnalyticsRecordable & Sendable
>: AnalyticsRecordable, Sendable {
  @usableFromInline
  let recorder: (repeat each R)

  @usableFromInline
  init(recorder: (repeat each R)) {
    self.recorder = recorder
  }

  @inlinable
  public func record(event: AnalyticsEvent) {
    for recorder in repeat each self.recorder {
      recorder.record(event: event)
    }
  }
}

// MARK: - Any Combine

/// Combines multiple specified analytics recorders into a single recorder.
///
/// ```swift
/// let analytics = combineAnalytics(.postHog, .console, TestAnalyticsRecorder())
/// ```
///
/// - Parameter recorder: A variadic list of ``AnalyticsRecordable``.
/// - Returns: An ``AnyCombinedAnalyticsRecorder``.
@inlinable
@_disfavoredOverload
public func combineAnalytics<each R: AnalyticsRecordable & Sendable>(
  _ recorder: repeat each R
) -> AnyCombinedAnalyticsRecorder {
  var recorders = [any AnalyticsRecordable & Sendable]()
  repeat recorders.append(each recorder)
  return AnyCombinedAnalyticsRecorder(recorders: recorders)
}

/// Combines multiple specified analytics recorders into a single recorder.
///
/// ```swift
/// let analytics = combineAnalytics([.postHog, .console, TestAnalyticsRecorder()])
/// ```
///
/// - Parameter recorders: An array of ``AnalyticsRecordable``.
/// - Returns: An ``AnyCombinedAnalyticsRecorder``.
@inlinable
public func combineAnalytics(
  _ recorders: [any AnalyticsRecordable & Sendable]
) -> AnyCombinedAnalyticsRecorder {
  AnyCombinedAnalyticsRecorder(recorders: recorders)
}

/// An ``AnalyticsRecordable`` type that combines an existential array of analytics recorders.
///
/// You create this type by calling ``combineAnalytics(_:)``.
public struct AnyCombinedAnalyticsRecorder: AnalyticsRecordable, Sendable {
  @usableFromInline
  let recorders: [any AnalyticsRecordable & Sendable]

  @usableFromInline
  init(recorders: [any AnalyticsRecordable & Sendable]) {
    self.recorders = recorders
  }

  @inlinable
  public func record(event: AnalyticsEvent) {
    for recorder in self.recorders {
      recorder.record(event: event)
    }
  }
}
