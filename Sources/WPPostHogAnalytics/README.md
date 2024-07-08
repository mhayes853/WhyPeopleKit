#  WPPostHogAnalytics

An implementation of the WPAnalyticsCore interface using the PostHog SDK.

## Overview

### `PostHogAnalyticsRecorder`

The primary `AnalyticsRecordable` conformance is `PostHogAnalyticsRecorder`. It uses `PostHogSDK.shared` under the hood. You can also use the `.postHog` extension property to get an instance.

```swift
func doSomeTracking(analytics: some AnalyticsRecordable) {
  // ...
}

doSomeTracking(analytics: .postHog)
``` 

### `CustomPostHogEvent`

If you want to use custom `AnalyticsEvent`s that would involve integrating directly with the PostHog SDK, you can use the `CustomPostHogEvent` protocol in combination with the `.postHog` extension method on `AnalyticsEvent`.

```swift
struct SetUserGroupEvent: Equatable, Sendable {
  let type: String
  let id: String
  let properties: [String: AnalyticsEvent.Value?]
}

extension SetUserGroupEvent: CustomPostHogEvent {
  func record(on sdk: PostHogSDK) {
    sdk.group(type: self.type, key: self.id, properties: self.properties.postHogProperties)
  }
}

extension AnaltyticsEvent {
  static func setUserGroup(
    type: String,
    id: String,
    properties: [String: AnalyticsEvent.Value?] = [:]
  ) -> Self {
    .postHog(SetUserGroupEvent(type: type, id: id, properties: properties))
  }
}

func doSomeTracking(analytics: some AnalyticsRecordable) {
  analytics.record(event: .setUserGroup(type: "Company", id: "123"))
}
```
