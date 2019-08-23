import Foundation

public class DateSupport {
    public static let hoursInDay: CGFloat = 24

    // Returns number between 0.0 and 1.0 to indicate how much of today has passed.
    public static func getPercentTodayPassed() -> CGFloat {
        return Date().getPercentDayPassed()
    }

    // Gets the date for 'days' number of days in the future (or past if days is negative)
    public static func getDate(forDaysInFuture days: Int) -> Date {
        return Date().advancedBy(days: days)
    }

    // Returns an array of dates between and including startDay and endDay.
    public static func getAllDates(between startDay: Date, and endDay: Date) -> [Date] {
        guard DayDate(date: startDay) < DayDate(date: endDay) else {
            return []
        }
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

    public static func getDate(fromDayOfYear dayOfYear: Int, forYear year: Int) -> Date {
        let cal = Calendar.current
        var dc = DateComponents()
        dc.era = Date().getEra()
        dc.year = year
        dc.month = 1
        dc.day = 1
        let firstDayOfYear = cal.date(from: dc)!
        return cal.date(byAdding: .day, value: dayOfYear, to: firstDayOfYear)!
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

    static func getZeroDate() -> Date {
        var dc = DateComponents()
        dc.era = 1
        dc.year = 1
        dc.month = 1
        dc.day = 1
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        return Calendar.current.date(from: dc)!
    }
}
