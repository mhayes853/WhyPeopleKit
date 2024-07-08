#  WPMixpanelAnalytics

An implementation of the WPAnalyticsCore interface using the Mixpanel SDK.

## Overview

### `MixpanelAnalyticsRecorder`

The primary `AnalyticsRecordable` conformance is `MixpanelAnalyticsRecorder`. It has a single constructor that requires a `MixpanelInstance`. You can also use the `.mixpanel` extension property to get an instance that uses `Mixpanel.mainInstance()`.

```swift
func doSomeTracking(analytics: some AnalyticsRecordable) {
  // ...
}

doSomeTracking(analytics: .mixpanel)
``` 

### `CustomMixpanelEvent`

If you want to use custom `AnalyticsEvent`s that would involve integrating directly with the Mixpanel SDK, you can use the `CustomMixpanelEvent` protocol in combination with the `.mixpanel` extension method on `AnalyticsEvent`.

```swift
struct SetUserGroupEvent: Equatable, Sendable {
  let type: String
  let id: String
  let properties: [String: AnalyticsEvent.Value?]
}

extension SetUserGroupEvent: CustomMixpanelEvent {
  func record(on instance: MixpanelInstance) {
    instance.setGroup(groupKey: self.type, groupID: self.id)
    instance.getGroup(groupKey: self.type, groupID: self.id)
      .set(properties: self.properties.mixpanelProperties)
  }
}

extension AnaltyticsEvent {
  static func setUserGroup(
    type: String,
    id: String,
    properties: [String: AnalyticsEvent.Value?] = [:]
  ) -> Self {
    .mixpanel(SetUserGroupEvent(type: type, id: id, properties: properties))
  }
}

func doSomeTracking(analytics: some AnalyticsRecordable) {
  analytics.record(event: .setUserGroup(type: "Company", id: "123"))
}
```
