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

    var hashValue: Int
    var day: Int
    var month: Int
    var year: Int
    var era: Int
    public var description: String {
        return "\(day)-\(month)-\(year)-\(era)"
    }
    var dateObj: Date {
        var dateComps: DateComponents = DateComponents()
        dateComps.day = self.day
        dateComps.month = self.month
        dateComps.year = self.year
        dateComps.era = self.era
        if let date = Calendar.current.date(from: dateComps) {
            return date
        }
        else {
            return Date()
        }
    }
    static var today: DayDate {
        return DayDate(date: Date())
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
                    }
                    else {
                        return lhs.day < rhs.day
                    }
                }
                else {
                    return lhs.month < rhs.month
                }
            }
            else {
                return lhs.year < rhs.year
            }
        }
        else {
            return lhs.era < rhs.era
        }
    }

    init(day: Int, month: Int, year: Int, era: Int) {
        self.day = day
        self.month = month
        self.year = year
        self.era = era
        self.hashValue = "\(day)-\(month)-\(year)-\(era)".hashValue
    }

    init(date: Date) {
        let cal = Calendar.current
        self.day = cal.component(.day, from: date)
        self.month = cal.component(.month, from: date)
        self.year = cal.component(.year, from: date)
        self.era = cal.component(.era, from: date)
        self.hashValue = "\(day)-\(month)-\(year)-\(era)".hashValue
    }

    init() {
        self.day = -1
        self.month = -1
        self.year = -1
        self.era = -1
        self.hashValue = "\(day)-\(month)-\(year)-\(era)".hashValue
    }

    func hasPassed() -> Bool {
        return self < DayDate.today
    }

    func isToday() -> Bool {
        return self == DayDate.today
    }

    func isWeekend() -> Bool {
        let cal = Calendar.current
        let weekDay = cal.component(.weekday, from: dateObj)
        return (weekDay == 1 || weekDay == 7)
    }

    func toSimpleString() -> String {

        let df = DateFormatter()
        df.dateFormat = "EEEE"
        let dayOfWeek = df.string(from: dateObj).capitalized.getFirstNCharacters(n: 3)
        let monthStr = df.monthSymbols[month-1].getFirstNCharacters(n: 3)
        return "\(dayOfWeek) \(day) \(monthStr)"
    }

}
