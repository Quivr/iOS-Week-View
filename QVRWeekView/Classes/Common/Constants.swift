//
//  Constants.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/7/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation
import UIKit

/**
 LayoutDefaults struct provides default values for all layout variables.
 */
struct LayoutDefaults {
    // MARK: - FONTS, LABEL AND TEXT COLOUR VALUES -

    // Default font of day labels
    static let dayLabelFont = UIFont.boldSystemFont(ofSize: 14)
    // Default text color of day labels
    static let dayLabelTextColor = UIColor.black
    // Text color of today day label
    static let dayLabelTodayTextColor = UIColor(red: 20/255, green: 66/255, blue: 111/255, alpha: 1.0)
    // Default minimum event label scaling
    static let dayLabelMinimumFontSize = CGFloat(8)
    // Date formats for day labels
    static let dayLabelDateFormats: [TextMode: String] = [.large: "E d MMM y", .normal: "E d MMM", .small: "d MMM"]
    // Default font of hour labels
    static let hourLabelFont = UIFont.boldSystemFont(ofSize: 12)
    // Default text color of hour labels
    static let hourLabelTextColor = UIColor.black
    // Default minimum event label scaling
    static let hourLabelMinimumFontSize = CGFloat(6)
    // Default hour label format
    static let hourLabelDateFormat: String = "HH"

    // Default font of events labels
    static let eventLabelFont = UIFont.boldSystemFont(ofSize: 12)
    // Thin font of event labels
    static let eventLabelThinFont = UIFont.systemFont(ofSize: 12)
    // Default text color of event labels
    static let eventLabelTextColor = UIColor.white
    // Default horizontal padding of text in event labels
    static let eventLabelHorizontalTextPadding = CGFloat(2)
    // Default vertical padding of text in event labels
    static let eventLabelVerticalTextPadding = CGFloat(2)

    // Default text of preview event
    static let previewEventText = "New Item"
    // Default color of the preview event
    static let previewEventColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
    // Default height of the preview event in hours
    static let previewEventHeightInHours = 2.0
    // Default precision of the preview event in minutes.
    static let previewEventPrecisionInMinutes = 15.0
    // Default show preview on long press
    static let showPreviewOnLongPress = true

    // MARK: - SIZES, BUFFERS AND LAYOUT -

    // Sizes of weekview elements
    static let defaultTopBarHeight = CGFloat(35)
    static let sideBarWidth = CGFloat(25)

    // Horizontal spacing of day view cells
    static let portraitDayViewHorizontalSpacing = CGFloat(5)
    static let landscapeDayViewHorizontalSpacing = CGFloat(1)

    // Vertical spacing of day view cells
    static let portraitDayViewVerticalSpacing = CGFloat(15)
    static let landscapeDayViewVerticalSpacing = CGFloat(10)

    // Height of all day events
    static let allDayEventHeight = CGFloat(40)
    // Vertical spacing of all day events
    static let allDayVerticalSpacing = CGFloat(5)
    // Spread all day events on x axis, if not true than spread will be made on y axis
    static let allDayEventsSpreadOnX = true

    // Initial height of day view cells
    static let dayViewCellHeight = CGFloat(1400)
    // Test width of day view cells - WARNING: ONLY USED FOR FRAME CALCULATION
    static let dayViewCellWidth = CGFloat(200)
    // Pattern of dashed separators in the day view cells
    static let mainSeparatorThickness = CGFloat(1)
    // Pattern of dashed separators in the day view cells
    static let dashedSeparatorPattern: [NSNumber] = [3, 1]
    // Pattern of dashed separators in the day view cells
    static let dashedSeparatorThickness = CGFloat(1)
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

    // Color of the background (behind the day view cells)
    static let backgroundColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1.0)
    // Color of the top bar (containing day labels)
    static let topBarColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
    // Color of the hour indicator displayed over the today day view cell.
    static let hourIndicatorColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)
    // Default color for a day view cell. These are days in the future (or today in the future) that are not weekends.
    static let defaultDayViewColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    // Color for day view cells that are in the future and weekends.
    static let weekendDayViewColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    // Color for passed day view cells that are not weekends.
    static let passedDayViewColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    // Color for passed day view cells that are weekend.
    static let passedWeekendDayViewColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1.0)
    // Color for today's view cell.
    static let todayViewColor = defaultDayViewColor
}

struct NibNames {
    // Nibname for fetching day view cell
    static let dayViewCell = "DayViewCell"
    // Nib name for fetching hour side bar view
    static let hourSideBarView = "HourSideBarView"
    // Nib name for fetching hour side bar view made by constraints
    static let constrainedHourSideBarView = "HourSideBarViewC"
    // Nib name for fetching the main week view.
    static let weekView = "WeekView"
}

struct CellKeys {
    static let dayViewCell = "DayViewCell"
}
