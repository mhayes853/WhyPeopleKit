import WPAnalyticsCore
import Testing

@Suite("AnalyticsEvent tests")
struct AnalyticsEventTests {
  @Test(
    "Equatable, Equal Values",
    arguments: [
      (AnalyticsEvent("hello"), .event(name: "hello", properties: [:])),
      (.identify(distinctId: "user"), .identify(distinctId: "user")),
      (.setUserProperties(["hello": "world"]), .setUserProperties(["hello": "world"])),
      (.opt(.in), .opt(.in)),
      (AnalyticsEvent.custom(CustomEvent(number: 1)), AnalyticsEvent.custom(CustomEvent(number: 1)))
    ]
  )
  func equal(e1: AnalyticsEvent, e2: AnalyticsEvent) {
    #expect(e1 == e2)
  }
  
  @Test(
    "Equatable, Non-Equal Values",
    arguments: [
      (AnalyticsEvent("hello"), .event(name: "hello", properties: ["prop": 1])),
      (AnalyticsEvent("hello"), .identify(distinctId: "user")),
      (.setUserProperties([:]), .opt(.in)),
      (AnalyticsEvent.custom(CustomEvent(number: 923880)), .opt(.in)),
      (AnalyticsEvent("hello"), .event(name: "hello", properties: ["prop": 1])),
      (.identify(distinctId: "user1"), .identify(distinctId: "user2")),
      (.setUserProperties(["hello": true]), .setUserProperties(["hello": false])),
      (.opt(.in), .opt(.out)),
      (
        AnalyticsEvent.custom(CustomEvent(number: 1)),
        AnalyticsEvent.custom(CustomEvent(number: 3))
      ),
      (
        AnalyticsEvent.custom(CustomEvent2(number: 1)),
        AnalyticsEvent.custom(CustomEvent(number: 1))
      )
    ]
  )
  func nonEqual(e1: AnalyticsEvent, e2: AnalyticsEvent) {
    #expect(e1 != e2)
  }
}

private struct CustomEvent: Equatable {
  let number: Int
}

private struct CustomEvent2: Equatable {
  let number: Int
}
