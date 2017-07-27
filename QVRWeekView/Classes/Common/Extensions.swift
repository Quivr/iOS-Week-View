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

    func getFirstNCharacters(n count: Int) -> String {
        return self.substring(to: self.index(self.startIndex, offsetBy: count))
    }
}

public extension Date {

    func getDayOfYear() -> Int {
        return (Calendar.current.ordinality(of: .day, in: .year, for: self)!-1)
    }

    func getDayOfWeek() -> Int {
        return (Calendar.current.component(.weekday, from: self)-1)
    }

    func getDayValue() -> Date {
        let todayComponents = self.getDayComponents()
        return Calendar.current.date(from: todayComponents)!
    }

    func getPercentDayPassed() -> CGFloat {

        let cal = Calendar.current
        let hour = Double(cal.component(.hour, from: self))
        let minutes = Double(cal.component(.minute, from: self))

        return CGFloat((hour/24) + (minutes/(60*24)))
    }

    func getNextDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    func getStartOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    func getEndOfDay() -> Date {
        var comps = DateComponents()
        comps.day = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: self.getStartOfDay())!
    }

    func getTimeInSeconds() -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let hours = Double(comps.hour!)
        let minutes = Double(comps.minute!)
        let seconds = Double(comps.second!)
        return hours + (minutes/60) + (seconds/60/60)
    }

    func date(withDayAdded days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func hasPassed() -> Bool {
        return (self.compare(Date()).rawValue == -1)
    }

    func isMidnight() -> Bool {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        return comps.hour == 0 && comps.minute == 0 && comps.second == 0
    }

    func isSameDayAs(_ day: Date) -> Bool {
        let todayComponents = day.getDayComponents()
        let selfComponents = self.getDayComponents()
        return todayComponents == selfComponents
    }

    func getDayComponents() -> DateComponents {
        let cal = Calendar.current
        let dayComponenets: Set<Calendar.Component> = [.day, .month, .year, .era]
        return cal.dateComponents(dayComponenets, from: self)
    }

    mutating func advanceBy(seconds sec: Int) {
        self = self.addingTimeInterval(TimeInterval(exactly: sec)!)
    }
}

extension CGFloat {

    func roundUpAdditionalHalf() -> CGFloat {
        return (self+0.5).roundedToNearestHalf()
    }

    func roundDownSubtractedHalf() -> CGFloat {
        return (self-0.5).roundedToNearestHalf()
    }

    func isEqual(to f: CGFloat, decimalPlaces dec: Int) -> Bool {
        let delta = CGFloat(1 / pow(10.0, Double(dec)))
        return abs(self - f) < delta
    }

    private func roundedToNearestHalf() -> CGFloat {
        return ((self*2).rounded())/2
    }
}
