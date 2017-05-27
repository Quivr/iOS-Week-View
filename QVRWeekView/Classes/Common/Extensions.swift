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

extension Date {
    
    func getDayOfYear() -> Int {
        return (Calendar.current.ordinality(of: .day, in: .year, for: self)!-1)
    }
    
    func getDayOfWeek() -> Int {
        return (Calendar.current.component(.weekday, from: self)-1)
    }
    
    func hasPassed() -> Bool {
        return (self.compare(Date()).rawValue == -1)
    }
    
    func isToday() -> Bool {
        
        return isSameDayAs(Date())
    }
    
    func isSameDayAs(_ day: Date) -> Bool {

        let todayComponents = day.getDayComponents()
        let selfComponents = self.getDayComponents()
        
        if todayComponents == selfComponents {
            return true
        }
        else {
            return false
        }
    }
    
    func isWeekend() -> Bool {
        
        let cal = Calendar.current
        let weekDay = cal.component(.weekday, from: self)
        return (weekDay == 1 || weekDay == 7)
    }
    
    func getPercentDayPassed() -> CGFloat {
        
        let cal = Calendar.current
        let hour = Double(cal.component(.hour, from: self))
        let minutes = Double(cal.component(.minute, from: self))
        
        return CGFloat((hour/24) + (minutes/(60*24)))
            
    }
    
    func getDayLabelString() -> String {
        
        let cal = Calendar.current
        let month:Int = cal.component(.month, from: self)
        let day:Int = cal.component(.day, from: self)
        
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        let dayOfWeek = df.string(from: self).capitalized.getFirstNCharacters(n: 3)
        let monthStr = df.monthSymbols[month-1].getFirstNCharacters(n: 3)
        
        return "\(dayOfWeek) \(day) \(monthStr)"
    }
    
    func getDaysInYear(withYearOffset offset: Int) -> Int {
        
        let cal = Calendar.current
        let year = cal.component(.year, from: self)
        var dateComps = DateComponents()
        dateComps.day = 1
        dateComps.month = 1
        dateComps.year = year + offset
        
        let firstJanuaryThisYear = cal.date(from: dateComps)!
        
        dateComps.year = year + 1 + offset
        
        let firstJanuaryNextYear = cal.date(from: dateComps)!
        return cal.dateComponents([.day], from: firstJanuaryThisYear, to: firstJanuaryNextYear).day!
    }
    
    private func getDayComponents() -> DateComponents {
        let cal = Calendar.current
        let dayComponenets:Set<Calendar.Component> = [.day, .month, .year, .era]
        return cal.dateComponents(dayComponenets, from: self)
    }
}

extension CGFloat {
    
    func roundUpAdditionalHalf() -> CGFloat {
        return (self+0.5).roundedToNearestHalf()
    }
    
    func roundDownSubtractedHalf() -> CGFloat {
        return (self-0.5).roundedToNearestHalf()
    }
    
    private func roundedToNearestHalf() -> CGFloat {
        return ((self*2).rounded())/2
    }
    
}
