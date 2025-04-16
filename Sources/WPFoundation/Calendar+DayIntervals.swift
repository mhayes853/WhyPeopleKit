import Foundation

extension Calendar {
  public func dayIntervals(from interval: DateInterval) -> [DateInterval] {
    //if self.isDate(interval.start, inSameDayAs: interval.end) {
    //  return [interval]
    //}
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
