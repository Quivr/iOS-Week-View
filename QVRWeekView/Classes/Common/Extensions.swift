//
//  Extensions.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/7/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation
import UIKit

extension String {
    // Gets first N character from self.
    func getFirstNCharacters(n count: Int) -> String {
        return "\(self[..<Index(utf16Offset: count, in: self)])"
    }
}

public extension Date {
    // Returns the day number of self in year.
    func getDayOfYear() -> Int {
        return (Calendar.current.ordinality(of: .day, in: .year, for: self)!-1)
    }

    // Gets day of week.
    func getDayOfWeek() -> Int {
        return (Calendar.current.component(.weekday, from: self)-1)
    }

    // Get era
    func getEra() -> Int {
        return Calendar.current.component(.era, from: self)
    }

    // Returns a date with day of self and time at 12pm
    func getDayValue() -> Date {
        var todayComponents = self.getDayComponents()
        todayComponents.hour = 12
        return Calendar.current.date(from: todayComponents)!
    }

    // Gets percent of this day passed.
    func getPercentDayPassed() -> CGFloat {

        let cal = Calendar.current
        let hour = Double(cal.component(.hour, from: self))
        let minutes = Double(cal.component(.minute, from: self))

        return CGFloat((hour/24) + (minutes/(60*24)))
    }

    // Returns next day date.
    func getNextDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    // Returns previous day date.
    func getPreviousDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    // Returns date for start of self.
    func getStartOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    // Return date for end of self.
    func getEndOfDay() -> Date {
        var comps = DateComponents()
        comps.day = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: self.getStartOfDay())!
    }

    // Returns a double which represents the time of self in terms of the hour.
    func getTimeInHours() -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let hours = Double(comps.hour!)
        let minutes = Double(comps.minute!)
        let seconds = Double(comps.second!)
        return hours + (minutes/60) + (seconds/60/60)
    }

    // Reverse of getTimeInHours(), applies a double representation of time in terms of hour to self.
    func applyTimeInHours(hourTime: Double) -> Date {
        let hours = Int(hourTime)
        var temp = (hourTime-Double(hours))*60
        let minutes = Int(temp)
        temp -= Double(minutes)
        let seconds = Int(temp*60)
        return self.withTimeSetTo(hour: hours, minutes: minutes, seconds: seconds)
    }

    // Returns a date object of self with hours, minutes and seconds set to paramter values.
    func withTimeSetTo(hour: Int, minutes: Int, seconds: Int) -> Date {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minutes
        comps.second = seconds
        return cal.date(byAdding: comps, to: self)!
    }

    // Returns true if self has passed.
    func hasPassed() -> Bool {
        return (self.compare(Date()).rawValue == -1)
    }

    // Returns true if self is midnight, up to minute precision.
    func isMidnight() -> Bool {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return comps.hour == 0 && comps.minute == 0
    }

    // Returns true if self is the midnight after given date.
    func isMidnight(afterDate date: Date) -> Bool {
        return self.isMidnight() && self.getPreviousDay().isSameDayAs(date)
    }

    // Returns true if self is same day as given day.
    func isSameDayAs(_ day: Date) -> Bool {
        let todayComponents = day.getDayComponents()
        let selfComponents = self.getDayComponents()
        return todayComponents == selfComponents
    }

    // Returns day components of self.
    func getDayComponents() -> DateComponents {
        let dayComponenets: Set<Calendar.Component> = [.day, .month, .year, .era]
        return Calendar.current.dateComponents(dayComponenets, from: self)
    }

    func dayDifference(withDate date: Date) -> Int {
        guard let selfDayOrd = Calendar.current.ordinality(of: .day, in: .era, for: self) else {
            return 0
        }
        guard let dateDayOrd = Calendar.current.ordinality(of: .day, in: .era, for: date) else {
            return 0
        }
        return selfDayOrd - dateDayOrd
    }

    // Returns date advanced by number of seconds.
    func advancedBy(seconds sec: Double) -> Date {
        return self.addingTimeInterval(sec)
    }

    // Returns date advanced by number of seconds.
    func advancedBy(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    // Returns date advanced by number of seconds.
    mutating func add(hours hour: Double) {
        self.addTimeInterval(hour*60*60)
    }
}

extension CGFloat {

    // Returns self incremented by 0.5 and rounded to nearest half.
    func roundUpAdditionalHalf() -> CGFloat {
        return (self+0.5).roundedToNearestHalf()
    }

    // Returns self decremented by 0.5 and rounded to nearest half.
    func roundDownSubtractedHalf() -> CGFloat {
        return (self-0.5).roundedToNearestHalf()
    }

    // Returns true if self equal to f to dec number of decimal places.
    func isEqual(to f: CGFloat, decimalPlaces dec: Int) -> Bool {
        let delta = CGFloat(1 / pow(10.0, Double(dec)))
        return abs(self - f) < delta
    }

    // Returns self rounded to nearest (0.5) half.
    private func roundedToNearestHalf() -> CGFloat {
        return ((self*2).rounded())/2
    }
}

extension Double {
    // Returns self rounded to nearest value. Value must be between 0 and 1, example: quarter (0.25)
    func roundToNearest(_ value: Double) -> Double {
        return ((self/value).rounded())*value
    }
}

extension Dictionary where Key == DayDate, Value == [String: EventData] {
    // Adds event to dictionary.
    mutating func addEvent(_ event: EventData, onDay dayDate: DayDate) {
        if self[dayDate] == nil {
            self[dayDate] = [event.id: event]
        }
        else {
            self[dayDate]![event.id] = event
        }
    }
}

extension Dictionary where Key == DayDate, Value == [EventData] {
    // Adds event to dictionary.
    mutating func addEvent(_ event: EventData, onDay dayDate: DayDate) {
        if self[dayDate] == nil {
            self[dayDate] = [event]
        }
        else {
            self[dayDate]!.append(event)
        }
    }
}
