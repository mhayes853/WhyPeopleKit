#  WPAnalyticsCore

A generic analytics interface.

## Overview

Analytics are an important part of improving any serious product, and there are many sdks and services to handle most of the grunt work. However, sprinkling direct analytics calls to a 3rd party service in various points throughout an application can lead to too much tangling between the 3rd party and application code. This can cause a few issues:
1. It makes it hard to switch to another analytics provider should the need arise.
2. It's hard to programatically inspect events recorded to 3rd party analytics sdks, which is especially problematic for automated testing.

This library provides generic types and a protocol for dealing with common analytics events, and even provides a way to inspect recorded events for testing purposes. It also provides a SwiftUI environment property for recording analytics in views.

```swift
struct SomeScreen: View {
  @Environment(\.analytics) var analytics

  var body: some View {
    VStack {
      // Rest of screen...
    }
    .onAppear { self.analytics.record(event: "viewed_some_screen") }
  }
}
```

In addition to this core library, adapter modules for both Mixpanel and PostHog can be found in this repo.

### `AnalyticsRecordable`

This protocol defines the basic functionallity for recording analytics. It has a singular `record` method requirement that is responsible for recording an instance of `AnalyticsEvent`.

This core library contains 5 utility implementations that you may find especially useful for testing or debugging:
1. `ConsoleAnalyticsRecorder` - Prints analytic events to the console.
2. `TestAnalyticsRecorder` - Records events in memory and allows for inspection of analytic events during testing.
3. `IssueReportingAnalyticsRecorder` - Reports an issue using swift-issue-reporting when an analytics event is recorder.
4. `NoopAnalyticsRecorder` - Does nothing when receiving anlytic events.
5. `VariadicCombinedAnalyticsRecorder/AnyCombinedAnalyticsRecorder` - Combines multiple analytics recorders into 1.

Additionally, you can find `MixpanelAnalyticsRecorder` and `PostHogAnalyticsRecorder` in WPMixpanelAnalytics and WPPostHogAnalytics respectively.

There is also an `analyticsRecordable` SwiftUI environment property defined as an extension on `EnvironmentValues` such that you can use the `AnalyticsRecordable` protocol in views.

### `AnalyticsEvent`

This enum describes a few cases of common events that are fundamental to most analytics providers. Those cases are:
- `.event` for the typical event with a name and a few properties.
- `.identify` which accepts a distinct user id, and represents an event to identify the current user.
- `.setUserProperties` for setting metadata properties on the current user.
- `.opt` for opting in and out of analytics tracking.

```swift
func doSomeTracking(analytics: some AnalyticsRecordable) {
  analytics.record(event: .opt(.in))
  analytics.record(event: .event(name: "some_event", properties: ["screen_id": 1]))
  analytics.record(event: .identify(distinctId: "some-user-id"))
  analytics.record(event: .setUserProperties(["is_vip": true]))
}
```

You can also initialize the `.event` case with a string literal, or with a plain initializer.

```swift
func doSomeMoreTracking(analytics: some AnalyticsRecordable) {
  analytics.record(event: "event_with_string_literal")
  analytics.record(event: AnalyticsEvent("event_with_initializer", properties: ["and": "properties"]))
}
```

If you want to tap into specific features of your analytics sdk, you can leverage the `.custom` case to pass a custom event to the provider. Custom cases are represented by `any Equatable & Sendable` types that you create. You then interpret your custom events in your own conformance of `AnalyticsRecordable`.

```swift
struct TrackChargeEvent: Equatable, Sendable {
  let amount: Double
  let properties: [String: Value?]
}

extension AnalyticsEvent {
  static func trackCharge(amount: Double, properties: [String: Value?]) -> Self {
    .custom(TrackChargeEvent(amount: amount, properties: properties))
  }
}

struct MyAnalyticsRecorder: AnalyticsRecordable {
  func record(event: AnalyticsEvent) {
    switch event {
      case let .event(name, properties):
        // ...

      case let .identify(distinctId):
        // ...

      case let .setUserProperties(properties):
        // ...

      case let .opt(status):
        // ...

      case let .custom(event):
        guard let event = event as? TrackChargeEvent else { return }
        // Record the event somehow...
    }
  }
}
```

### Combining

The library ships with a helper function to combine multiple analytics recorders into 1.

```swift
let analytics = combineAnalytics(.postHog, .console, .mixpanel)
```

### Testing

For testing you can use `TestAnalyticsRecorder` to inspect any recorded events from the system under test. Since `AnalyticsEvent` conforms to `Equatable`, inspecting is trivial.

```swift
@Test("Records Detail Presentation")
func recordsScreenCapture() {
  let analytics = TestAnalyticsRecorder()
  let model = FeatureModel(analytics)
  model.detailButtonTapped()
  #expect(analytics.didRecord(event: "detail_presented"))
}
```
