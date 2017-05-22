//
//  Constants.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/7/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation
import UIKit

struct LayoutDefaults {
    
    // MARK: - FONTS -
    
    static let dayLabelFontSize = CGFloat(14)
    static let hourLabelFontSize = CGFloat(12)
    static let eventLabelFontSize = CGFloat(12)
    static let eventLabelMinimumScale = CGFloat(0.85)
    
    // MARK: - SIZES -
    
    // Best not to change these
    static let topBarHeight = CGFloat(35)
    static let sideBarWidth = CGFloat(25)
    
    // These can be changed
    static let portraitDayViewHorizontalSpacing = CGFloat(5)
    static let landscapeDayViewHorizontalSpacing = CGFloat(1)
    
    static let portraitDayViewVerticalSpacing = CGFloat(10)
    static let landscapeDayViewVerticalSpacing = CGFloat(5)
    
    static let dayViewCellHeight = CGFloat(1400)
    
    // These can be changed easily
    static let visibleDaysPortrait = CGFloat(2)
    static let visibleDaysLandscape = CGFloat(7)
    
    // Changing these doesn't add much but risks breaking the smoothness and niceness
    static let velocityOffsetMultiplier = CGFloat(1.5)
    
    static let minimumZoom = CGFloat(0.75)
    static let maximumZoom = CGFloat(3.0)
    
    // This is added for some extra room at the bottom
    static let bottomBufferHeight = CGFloat(20)
    
    // MARK: - COLOURS -
    
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
    static let weekView = "WeekView"
}
