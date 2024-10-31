import Testing
import WPAnalyticsCore

@Suite("AnalyticsRecordable+CombineTests")
struct AnalyticsRecordableCombineTests {
  @Test("Records Events to Multiple Analytics Recorders")
  func multiple() {
    let r1 = TestAnalyticsRecorder()
    let r2 = TestAnalyticsRecorder()
    let r3 = TestAnalyticsRecorder()
    let r4 = TestAnalyticsRecorder()
    let recorder = combineAnalytics(r1, r2, r3, r4)
    let event = AnalyticsEvent("some_event", properties: ["test": 64])
    recorder.record(event: event)

    #expect(r1.didRecord(event: event))
    #expect(r2.didRecord(event: event))
    #expect(r3.didRecord(event: event))
    #expect(r4.didRecord(event: event))
  }
}
