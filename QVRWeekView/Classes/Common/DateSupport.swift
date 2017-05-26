
//
//  Support.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/7/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation


class DateSupport {
    
    static let secondsInADay:Int = 60*60*24
    static let hoursInDay:CGFloat = 24
    
    static func getDayDate(forDaysInFuture days:Int) -> Date {
        
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: days, to: Date())!
        
        return date
    }

}
