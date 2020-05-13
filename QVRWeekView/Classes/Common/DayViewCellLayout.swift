//
//  DayViewCellLayout.swift
//  Pods
//
//  Created by Reinert Lemmens on 13/05/2020.
//

import Foundation

class DayViewCellLayout {
    // Default color of the day view cells. These are all days that are not weekends and not passed.
    var defaultDayViewColor: UIColor = LayoutDefaults.defaultDayViewColor
    // Color for today's view cell.
    var todayViewColor: UIColor = LayoutDefaults.todayViewColor
    // Color for all day view cells that are weekend days.
    var weekendDayViewColor: UIColor = LayoutDefaults.weekendDayViewColor
    // Color for all day view cells that are passed weekend days.
    var passedWeekendDayViewColor: UIColor = LayoutDefaults.passedWeekendDayViewColor
    // Color for all day view cells that are passed days and not weekends.
    var passedDayViewColor: UIColor = LayoutDefaults.passedDayViewColor

    // Thickness (height) of the current hour indicator.
    var hourIndicatorThickness: CGFloat = LayoutDefaults.hourIndicatorThickness
    // Color of the current hour indicator.
    var hourIndicatorColor: UIColor = LayoutDefaults.backgroundColor
    // Thickness of the main hour separators in the day view cells. Main separators are full lines and not dashed.
    var mainSeparatorThickness: CGFloat = LayoutDefaults.mainSeparatorThickness
    // Color of the main hour separators in the day view cells. Main separators are full lines and not dashed.
    var mainSeparatorColor: UIColor = LayoutDefaults.hourIndicatorColor
    // Thickness of the dashed/dotted hour separators in the day view cells.
    var dashedSeparatorThickness: CGFloat = LayoutDefaults.dashedSeparatorThickness
    // Color of the dashed/dotted hour separators in the day view cells.
    var dashedSeparatorColor: UIColor = LayoutDefaults.backgroundColor
    // Sets the pattern for the dashed/dotted separators.
    var dashedSeparatorPattern: [NSNumber] = LayoutDefaults.dashedSeparatorPattern

    // Font used for all event labels contained in the day view cells.
    var eventLabelFont: UIFont = LayoutDefaults.eventLabelFont
    //Thin font used for all event labels contained in the day view cells.
    var eventLabelInfoFont: UIFont = LayoutDefaults.eventLabelThinFont
    // Text color for all event labels contained in the day view cells.
    var eventLabelTextColor: UIColor = LayoutDefaults.eventLabelTextColor
    // Horizontal padding of the text within event labels.
    var eventLabelHorizontalTextPadding: CGFloat = LayoutDefaults.eventLabelHorizontalTextPadding
    // Vertical padding of the text within event labels.
    var eventLabelVerticalTextPadding: CGFloat = LayoutDefaults.eventLabelVerticalTextPadding

    // The color of the preview event.
    var previewEventColor: UIColor = LayoutDefaults.previewEventColor
    // The text shown inside the preview event.
    var previewEventText: String = LayoutDefaults.previewEventText
    // When enabled a preview event will be displayed on a long press.
    var showPreview: Bool = LayoutDefaults.showPreviewOnLongPress
    // The number of minutes the preview event will snap to.
    var previewEventMinutePrecision: Double = LayoutDefaults.previewEventPrecisionInMinutes
    // Height of the preview event in hours.
    var previewEventHourHeight: Double = LayoutDefaults.previewEventHeightInHours
}
