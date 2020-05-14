//
//  DayViewCellLayout.swift
//  Pods
//
//  Created by Reinert Lemmens on 13/05/2020.
//

import Foundation

class DayViewCellLayout {

    // Function is called when one of the properties changes
    var update: (() -> Void)?

    // Default color of the day view cells. These are all days that are not weekends and not passed.
    var defaultDayViewColor: UIColor = LayoutDefaults.defaultDayViewColor { didSet { update?() } }
    // Color for today's view cell.
    var todayViewColor: UIColor = LayoutDefaults.todayViewColor { didSet { update?() } }
    // Color for all day view cells that are weekend days.
    var weekendDayViewColor: UIColor = LayoutDefaults.weekendDayViewColor { didSet { update?() } }
    // Color for all day view cells that are passed weekend days.
    var passedWeekendDayViewColor: UIColor = LayoutDefaults.passedWeekendDayViewColor { didSet { update?() } }
    // Color for all day view cells that are passed days and not weekends.
    var passedDayViewColor: UIColor = LayoutDefaults.passedDayViewColor { didSet { update?() } }
    // Whether or not to show time overlay on today day view cell
    var showTimeOverlay: Bool = true { didSet { update?() } }

    // Thickness (height) of the current hour indicator.
    var hourIndicatorThickness: CGFloat = LayoutDefaults.hourIndicatorThickness { didSet { update?() } }
    // Color of the current hour indicator.
    var hourIndicatorColor: UIColor = LayoutDefaults.hourIndicatorColor { didSet { update?() } }
    // Thickness of the main hour separators in the day view cells. Main separators are full lines and not dashed.
    var mainSeparatorThickness: CGFloat = LayoutDefaults.mainSeparatorThickness { didSet { update?() } }
    // Color of the main hour separators in the day view cells. Main separators are full lines and not dashed.
    var mainSeparatorColor: UIColor = LayoutDefaults.backgroundColor { didSet { update?() } }
    // Thickness of the dashed/dotted hour separators in the day view cells.
    var dashedSeparatorThickness: CGFloat = LayoutDefaults.dashedSeparatorThickness { didSet { update?() } }
    // Color of the dashed/dotted hour separators in the day view cells.
    var dashedSeparatorColor: UIColor = LayoutDefaults.backgroundColor { didSet { update?() } }
    // Sets the pattern for the dashed/dotted separators.
    var dashedSeparatorPattern: [NSNumber] = LayoutDefaults.dashedSeparatorPattern { didSet { update?() } }

    // Font used for all event labels contained in the day view cells.
    var eventLabelFont: UIFont = LayoutDefaults.eventLabelFont { didSet { update?() } }
    //Thin font used for all event labels contained in the day view cells.
    var eventLabelInfoFont: UIFont = LayoutDefaults.eventLabelThinFont { didSet { update?() } }
    // Text color for all event labels contained in the day view cells.
    var eventLabelTextColor: UIColor = LayoutDefaults.eventLabelTextColor { didSet { update?() } }
    // Horizontal padding of the text within event labels.
    var eventLabelHorizontalTextPadding: CGFloat = LayoutDefaults.eventLabelHorizontalTextPadding { didSet { update?() } }
    // Vertical padding of the text within event labels.
    var eventLabelVerticalTextPadding: CGFloat = LayoutDefaults.eventLabelVerticalTextPadding { didSet { update?() } }
    // Determines style the event layers
    var eventStyleCallback: EventStlyeCallback? { didSet { update?() } }

    // The color of the preview event.
    var previewEventColor: UIColor = LayoutDefaults.previewEventColor { didSet { update?() } }
    // The text shown inside the preview event.
    var previewEventText: String = LayoutDefaults.previewEventText { didSet { update?() } }
    // When enabled a preview event will be displayed on a long press.
    var showPreview: Bool = LayoutDefaults.showPreviewOnLongPress { didSet { update?() } }
    // The number of minutes the preview event will snap to.
    var previewEventMinutePrecision: Double = LayoutDefaults.previewEventPrecisionInMinutes { didSet { update?() } }
    // Height of the preview event in hours.
    var previewEventHourHeight: Double = LayoutDefaults.previewEventHeightInHours { didSet { update?() } }
}
