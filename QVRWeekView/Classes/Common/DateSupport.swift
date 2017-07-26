import Foundation

class DateSupport {

    static let secondsInADay: Int = 60*60*24
    static let hoursInDay: CGFloat = 24

    static func getPercentTodayPassed() -> CGFloat {
        return Date().getPercentDayPassed()
    }

    static func getDate(forDaysInFuture days: Int) -> Date {

        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: days, to: Date())!
        return date
    }

    static func getAllDaysBetween (_ startDay: Date, and endDay: Date) -> [Date]{

        var cursorDay = startDay
        var allDays: [Date] = []
        while !cursorDay.isSameDayAs(endDay.getNextDay()) {
            allDays.append(cursorDay.getDayValue())
            cursorDay = cursorDay.getNextDay()
        }

        return allDays
    }

}
