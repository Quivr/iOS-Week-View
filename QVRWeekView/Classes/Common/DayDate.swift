//
//  DayDate.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/26/17.
//
//

import Foundation
import UIKit

struct DayDate: Hashable, Comparable, CustomStringConvertible {

    let day: Int
    let month: Int
    let year: Int
    let era: Int
    var dateObj: Date {
        var dateComps: DateComponents = DateComponents()
        dateComps.day = self.day
        dateComps.month = self.month
        dateComps.year = self.year
        dateComps.era = self.era
        dateComps.hour = 12
        if let date = Calendar.current.date(from: dateComps) {
            return date
        }
        else {
            return Date()
        }
    }
    var hashValue: Int {
        return "\(day)-\(month)-\(year)-\(era)".hashValue
    }

    var simpleString: String {
        return "\(dayOfWeek) \(day) \(monthStr)"
    }

    var dayOfWeek: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        return df.string(from: dateObj).capitalized.getFirstNCharacters(n: 3)
    }

    var monthStr: String {
        return DateFormatter().monthSymbols[month-1].getFirstNCharacters(n: 3)
    }

    public var description: String {
        return "\(day)-\(month)-\(year)-\(era)"
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

    static func == (lhs: DayDate, rhs: DayDate) -> Bool {
        return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year && lhs.era == rhs.era
    }

    static func < (lhs: DayDate, rhs: DayDate) -> Bool {
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

    func getDayDateMonday() -> DayDate {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self.dateObj)
        return DayDate(date: cal.date(from: comps)!)
    }

    func getDayDateWith(daysAdded days: Int) -> DayDate {
        return DayDate(date: Calendar.current.date(byAdding: .day, value: days, to: self.dateObj)!)
    }
}
