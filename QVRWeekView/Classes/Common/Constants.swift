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

    // MARK: - FONTS, LABEL AND TEXT COLOUR VALUES -

    // Default font of day labels
    static let dayLabelFont = UIFont.boldSystemFont(ofSize: 14)
    // Default text color of day labels
    static let dayLabelTextColor = UIColor.black
    // Default minimum event label scaling
    static let dayLabelMinimumScale = CGFloat(0.4)

    // Default font of hour labels
    static let hourLabelFont = UIFont.systemFont(ofSize: 12)
    // Default text color of hour labels
    static let hourLabelTextColor = UIColor.black
    // Default minimum event label scaling
    static let hourLabelMinimumScale = CGFloat(0.5)

    // Default font of events labels
    static let eventLabelFont = UIFont.boldSystemFont(ofSize: 12)
    // Default text color of event labels
    static let eventLabelTextColor = UIColor.white
    // Default minimum event label scaling
    static let eventLabelMinimumScale = CGFloat(0.85)

    // MARK: - SIZES, BUFFERS AND LAYOUT -

    // Sizes of weekview elements
    static let topBarHeight = CGFloat(35)
    static let sideBarWidth = CGFloat(25)

    // Horizontal spacing of day view cells
    static let portraitDayViewHorizontalSpacing = CGFloat(5)
    static let landscapeDayViewHorizontalSpacing = CGFloat(1)

    // Vertical spacing of day view cells
    static let portraitDayViewVerticalSpacing = CGFloat(15)
    static let landscapeDayViewVerticalSpacing = CGFloat(10)

    // Initial height of day view cells
    static let dayViewCellHeight = CGFloat(1400)
    // Test width of day view cells - WARNING: ONLY USED FOR FRAME CALCULATION
    static let dayViewCellWidth = CGFloat(200)
    // Pattern of dashed seperators in the day view cells
    static let mainSeperatorThickness = CGFloat(1)
    // Pattern of dashed seperators in the day view cells
    static let dashedSeperatorPattern: [NSNumber] = [3, 1]
    // Pattern of dashed seperators in the day view cells
    static let dashedSeperatorThickness = CGFloat(1)
    // Thickness of hour indicator in the day view cells
    static let hourIndicatorThickness = CGFloat(3)

    // Number of visible days
    static let visibleDaysPortrait = CGFloat(2)
    static let visibleDaysLandscape = CGFloat(7)

    // Multiplier for scrolling sensitivity
    static let velocityOffsetMultiplier = CGFloat(0.75)

    // Minimum and maximum zoom of scroll view
    static let minimumZoom = CGFloat(0.75)
    static let maximumZoom = CGFloat(3.0)

    // MARK: - COLOURS -

    static let backgroundColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1.0)
    static let topBarColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)

    static let hourIndicatorColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)

    static let defaultDayViewColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    static let weekendDayViewColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
    static let passedDayViewColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    static let passedWeekendDayViewColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1.0)
}

struct NibNames {
    static let dayViewCell = "DayViewCell"
    static let eventView = "EventView"
    static let hourSideBarView = "HourSideBarView"
    static let constrainedHourSideBarView = "HourSideBarViewC"
    static let weekView = "WeekView"
}

struct CellKeys {
    static let dayViewCell = "DayViewCell"
}
