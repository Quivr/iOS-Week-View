import Foundation

public class DateSupport {

    public static let secondsInADay: Int = 60*60*24
    public static let hoursInDay: CGFloat = 24

    public static func getPercentTodayPassed() -> CGFloat {
        return Date().getPercentDayPassed()
    }

    public static func getDate(forDaysInFuture days: Int) -> Date {

        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: days, to: Date())!
        return date
    }

    public static func getAllDates(between startDay: Date, and endDay: Date) -> [Date] {
        var cursorDay = startDay
        var allDays: [Date] = []
        while !cursorDay.isSameDayAs(endDay.getNextDay()) {
            allDays.append(cursorDay.getDayValue())
            cursorDay = cursorDay.getNextDay()
        }

        return allDays
    }

    static func getAllDayDates(between startDay: DayDate, and endDay: DayDate) -> [DayDate] {
        var cursorDay = startDay.dateObj
        var allDays: [DayDate] = []
        while !cursorDay.isSameDayAs(endDay.dateObj.getNextDay()) {
            allDays.append(DayDate(date: cursorDay))
            cursorDay = cursorDay.getNextDay()
        }

        return allDays
    }

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
