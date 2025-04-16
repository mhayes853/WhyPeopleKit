import Foundation

extension Calendar {
  /// Splits the specified `interval` into individual day intervals.
  ///
  /// - Parameter interval: The date interval to split.
  /// - Returns: An array of date intervals representing each day within the specified interval.
  public func dayIntervals(from interval: DateInterval) -> [DateInterval] {
    var intervals = [DateInterval]()
    var currentDate = interval.start
    while currentDate < interval.end {
      let nextDate = self.startOfDay(for: self.date(byAdding: .day, value: 1, to: currentDate)!)
      let nextEndDate = min(self.date(byAdding: .second, value: -1, to: nextDate)!, interval.end)
      intervals.append(DateInterval(start: currentDate, end: nextEndDate))
      currentDate = nextDate
    }
    return intervals
  }
}
