//
//  Constants.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/7/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation
import UIKit

struct LayoutConsts {
    
    // This is added for some extra room at the bottom
    static let bottomBufferHeight = CGFloat(20)
    // Number of days inside a period
    static let periodLength = 7
    // Number of periods rendered on screen
    static let numberOfPeriods = 3

}

struct LayoutDefaults {
    
    // Best not to change these
    static let topBarHeight = CGFloat(35)
    static let sideBarWidth = CGFloat(25)
    
    // These can be changed
    static let portraitDayViewSideSpacing = CGFloat(5)
    static let landscapeDayViewSideSpacing = CGFloat(1)
    static let dayViewMaximumTopSpacing = CGFloat(15)
    static let dayViewCellHeight = CGFloat(55)
    
    // These can be changed easily
    static let visibleDaysPortrait = CGFloat(2)
    static let visibleDaysLandscape = CGFloat(7)
    
    // Changing these doesn't add much but risks breaking the smoothness and niceness
    static let velocityOffsetMultiplier = CGFloat(1.5)
    static let dayLabelFontSize = CGFloat(14)
    
    static let minimumZoom = CGFloat(0.75)
    static let maximumZoom = CGFloat(3.0)
    
    static let backgroundGray = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
    static let topBarGray = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    
    static let overlayColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.8)
    static let overlayIndicatorColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.9)
    
    static let todayLabelColor = UIColor(red: 50/255, green: 150/255, blue: 50/255, alpha: 1.0)
    static let defaultLabelColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0)
    
    static let mainSeperatorColor = LayoutDefaults.backgroundGray
    static let secondarySeperatorColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
    
    static let defaultDayViewColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    static let weekendDayViewColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
}

struct NibNames {
    static let dayView = "DayView"
    static let eventView = "EventView"
    static let hourSideBarView = "HourSideBarView"
    static let calendarView = "CalendarView"
}

enum Direction {
    case none
    case left
    case right
}
