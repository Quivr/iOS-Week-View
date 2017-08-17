import Foundation

public class DateSupport {

    // TODO: REPLACE WITH CUSTOMIZABLE HOUR FORMAT GENERATION IN HOUR SIDE BAR VIEW
    public static let hoursInDay: CGFloat = 24

    // Returns number between 0.0 and 1.0 to indicate how much of today has passed.
    public static func getPercentTodayPassed() -> CGFloat {
        return Date().getPercentDayPassed()
    }

    // Gets the date for 'days' number of days in the future (or past if days is negative)
    public static func getDate(forDaysInFuture days: Int) -> Date {
        return Date().date(withDayAdded: days)
    }

    // Returns an array of dates between and including startDay and endDay.
    public static func getAllDates(between startDay: Date, and endDay: Date) -> [Date] {
        var cursorDay = startDay
        var allDays: [Date] = []
        while !cursorDay.isSameDayAs(endDay.getNextDay()) {
            allDays.append(cursorDay.getDayValue())
            cursorDay = cursorDay.getNextDay()
        }

        return allDays
    }

    // Returns an array of DayDates between and including startDay and endDay.
    static func getAllDayDates(between startDay: DayDate, and endDay: DayDate) -> [DayDate] {
        return getAllDates(between: startDay.dateObj, and: endDay.dateObj).map({ (item) -> DayDate in
            return DayDate(date: item)
        })
    }

    // Gets the number of days in the year.
    public static func getDaysInYear(_ year: Int) -> Int {

        let cal = Calendar.current
        var dateComps = DateComponents()
        dateComps.day = 1
        dateComps.month = 1
        dateComps.year = year
        let firstJanuaryThisYear = cal.date(from: dateComps)!

        dateComps.year = year + 1
        let firstJanuaryNextYear = cal.date(from: dateComps)!

        return cal.dateComponents([.day], from: firstJanuaryThisYear, to: firstJanuaryNextYear).day!
    }

}
