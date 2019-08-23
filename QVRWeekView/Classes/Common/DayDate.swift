//
//  DayDate.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/26/17.
//
//

import Foundation
import UIKit

/**
 Enum stores the text mode that the day date should return.
 */
public enum TextMode {
    case large
    case normal
    case small
}

/**
 Day date class is used as a reliable way to assign a day to things such as dayViewCells and dictionaries
 storing event and frame data. DayDates are not influenced by timezones and thus the date it has been given will
 remain. DayDates are also easy to compare, print as strings and are hashable.
 */
public struct DayDate: Hashable, Comparable, CustomStringConvertible, Strideable {
    let day: Int
    let month: Int
    let year: Int
    let era: Int

    public var description: String {
        return "\(day)-\(month)-\(year)-\(era)"
    }

    var dateObj: Date {
        var dateComps = dateComponents
        dateComps.hour = 12
        return Calendar.current.date(from: dateComps)!
    }

    var largeString: String {
        return getString(forMode: .large)
    }

    var defaultString: String {
        return getString(forMode: .normal)
    }

    var smallString: String {
        return self.getString(forMode: .small)
    }

    var dayInYear: Int {
        return self.dateObj.getDayOfYear()
    }

    private var dateComponents: DateComponents {
        var dateComps: DateComponents = DateComponents()
        dateComps.day = self.day
        dateComps.month = self.month
        dateComps.year = self.year
        dateComps.era = self.era
        return dateComps
    }

    static var today: DayDate {
        return DayDate(date: Date())
    }

    init(day: Int, month: Int, year: Int, era: Int) {
        self.day = day
        self.month = month
        self.year = year
        self.era = era
    }

    init(date: Date) {
        let cal = Calendar.current
        self.day = cal.component(.day, from: date)
        self.month = cal.component(.month, from: date)
        self.year = cal.component(.year, from: date)
        self.era = cal.component(.era, from: date)
    }

    init() {
        self.day = -1
        self.month = -1
        self.year = -1
        self.era = -1
    }

    public static func == (lhs: DayDate, rhs: DayDate) -> Bool {
        return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year && lhs.era == rhs.era
    }

    public static func < (lhs: DayDate, rhs: DayDate) -> Bool {
        if lhs.era == rhs.era {
            if lhs.year == rhs.year {
                if lhs.month == rhs.month {
                    if lhs.day == rhs.day {
                        return false
                    } else { return lhs.day < rhs.day }
                } else { return lhs.month < rhs.month }
            } else { return lhs.year < rhs.year }
        } else { return lhs.era < rhs.era }
    }

    static func + (lhs: DayDate, rhs: Int) -> DayDate {
        return DayDate(day: lhs.day + rhs, month: lhs.month, year: lhs.year, era: lhs.era)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(month)
        hasher.combine(year)
        hasher.combine(era)
    }

    func getString(forMode mode: TextMode) -> String {
        let df = DateFormatter()
        df.dateFormat = TextVariables.dayLabelDateFormats[mode]
        var locale = NSLocale.current
        if let customLocale = TextVariables.dayLabelDateLocale {
            locale = customLocale
        }
        df.locale = locale
        return df.string(from: self.dateObj)
    }

    func hasPassed() -> Bool {
        return self <= DayDate.today
    }

    func isToday() -> Bool {
        return self == DayDate.today
    }

    func isWeekend() -> Bool {
        let cal = Calendar.current
        let weekDay = cal.component(.weekday, from: dateObj)
        return (weekDay == 1 || weekDay == 7)
    }

    func getDateWithTime(hours: Int, minutes: Int, seconds: Int) -> Date {
        var comps = dateComponents
        comps.hour = hours
        comps.minute = minutes
        comps.second = seconds
        return Calendar.current.date(from: comps)!
    }

    func getDayDateMonday() -> DayDate {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self.dateObj)
        return DayDate(date: cal.date(from: comps)!)
    }

    func getDayDateWith(daysAdded days: Int) -> DayDate {
        return DayDate(date: self.dateObj.advancedBy(days: days))
    }

    public typealias Stride = Int

    public func distance(to other: DayDate) -> Int {
        return abs(dateObj.dayDifference(withDate: other.dateObj))
    }

    public func advanced(by n: Int) -> DayDate {
        return getDayDateWith(daysAdded: n)
    }
}
