import Testing
import WPFoundation
import WPMixpanelAnalytics

@Suite("AnalyticsEventValue+MixpanelValue tests")
struct AnalyticsEventValueMixpanelValueTests {
  @Test("AnalyticsEvent.Value to MixpanelType")
  func mixpanelValue() {
    let mixpanelValues: [String: any MixpanelType] = [
      "hello": "world",
      "test": 1,
      "largeInt": Int(truncatingIfNeeded: Int64.max),
      "bool": true,
      "nil": NSNull(),
      "date": Date(staticISO8601: "2022-04-01T00:00:00+0000"),
      "url": URL(string: "https://www.google.com")!,
      "double": 0.1,
      "array": [true, 1, NSNull()] as [any MixpanelType],
      "dict": ["array": [""]]
    ]
    let values: [String: AnalyticsEvent.Value?] = [
      "hello": "world",
      "test": 1,
      "largeInt": .integer(Int64.max),
      "bool": true,
      "nil": nil,
      "date": .date(Date(staticISO8601: "2022-04-01T00:00:00+0000")),
      "url": .url(URL(string: "https://www.google.com")!),
      "double": 0.1,
      "array": .array([true, 1, nil]),
      "dict": ["array": [""]]
    ]
    #expect(mixpanelValues.equals(rhs: values.mixpanelProperties))
  }
}
