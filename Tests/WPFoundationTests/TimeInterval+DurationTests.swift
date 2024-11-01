import WPFoundation
import Testing

@Suite("TimeInterval+Duration tests")
struct TimeIntervalDurationTests {
  @Test("Duration to TimeInterval")
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  func convert() async throws {
    let duration = Duration.milliseconds(3500)
    let timeInterval = TimeInterval(duration: duration)
    #expect(timeInterval == 3.5)
  }
}
