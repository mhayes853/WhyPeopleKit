import CustomDump
import Testing
import WPFoundation

@Suite("Calendar+DayIntervals tests")
struct CalendarDayIntervalsTests {
  @Test("Same Day Interval, Returns Existing Interval")
  func sameDayIntervalReturnsExistingInterval() {
    let calendar = Calendar.gregorianUTC
    let interval = DateInterval(
      start: Date(staticISO8601: "2025-04-15T12:29:28+0000"),
      duration: 60 * 5
    )
    expectNoDifference(calendar.dayIntervals(from: interval), [interval])
  }

  @Test("Interval Split Across 1 Day, Returns 2 Intervals")
  func intervalSplitAcrossOneDayReturnsTwoIntervals() {
    let calendar = Calendar.gregorianUTC
    let interval = DateInterval(
      start: Date(staticISO8601: "2025-04-15T12:29:28+0000"),
      end: Date(staticISO8601: "2025-04-16T04:37:19+0000")
    )
    expectNoDifference(
      calendar.dayIntervals(from: interval),
      [
        DateInterval(
          start: Date(staticISO8601: "2025-04-15T12:29:28+0000"),
          end: Date(staticISO8601: "2025-04-15T23:59:59+0000")
        ),
        DateInterval(
          start: Date(staticISO8601: "2025-04-16T00:00:00+0000"),
          end: Date(staticISO8601: "2025-04-16T04:37:19+0000")
        )
      ]
    )
  }

  @Test("Interval Split Across Multiple Days, Returns Multiple Intervals")
  func intervalSplitAcrossMultipleDaysReturnsMultipleIntervals() {
    let calendar = Calendar.gregorianUTC
    let interval = DateInterval(
      start: Date(staticISO8601: "2025-04-15T12:29:28+0000"),
      end: Date(staticISO8601: "2025-04-18T04:37:19+0000")
    )
    expectNoDifference(
      calendar.dayIntervals(from: interval),
      [
        DateInterval(
          start: Date(staticISO8601: "2025-04-15T12:29:28+0000"),
          end: Date(staticISO8601: "2025-04-15T23:59:59+0000")
        ),
        DateInterval(
          start: Date(staticISO8601: "2025-04-16T00:00:00+0000"),
          end: Date(staticISO8601: "2025-04-16T23:59:59+0000")
        ),
        DateInterval(
          start: Date(staticISO8601: "2025-04-17T00:00:00+0000"),
          end: Date(staticISO8601: "2025-04-17T23:59:59+0000")
        ),
        DateInterval(
          start: Date(staticISO8601: "2025-04-18T00:00:00+0000"),
          end: Date(staticISO8601: "2025-04-18T04:37:19+0000")
        )
      ]
    )
  }
}
