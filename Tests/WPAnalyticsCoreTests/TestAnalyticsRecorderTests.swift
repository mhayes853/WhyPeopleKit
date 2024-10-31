import Testing
import WPAnalyticsCore

@Suite("TestAnalyticsRecorder tests")
struct TestAnalyticsRecorderTests {
  @Test(
    "Count of events",
    arguments: [
      (AnalyticsEvent("test"), 2),
      (AnalyticsEvent.custom(420), 1),
      (.setUserProperties([:]), 3),
      (.identify(distinctId: "user"), 0)
    ]
  )
  func count(event: AnalyticsEvent, count: Int) async throws {
    let e1 = AnalyticsEvent("test")
    let e2 = AnalyticsEvent.custom(420)
    let e3 = AnalyticsEvent.setUserProperties([:])
    let recorder = TestAnalyticsRecorder()
    recorder.record(event: e1)
    recorder.record(event: "test")
    recorder.record(event: e2)
    recorder.record(event: e3)
    recorder.record(event: e3)
    recorder.record(event: e3)
    #expect(recorder.count(of: event) == count)
  }
}
