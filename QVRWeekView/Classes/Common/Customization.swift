//
//  Customization.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 18/08/2017.
//

import Foundation

/**
 This WeekView extension contains all public computed properties which are exposed as customizable properties.
 */
public extension WeekView {
    // MARK: - DAYSCROLLVIEW CUSTOMIZATION -

    /**
     Number of visible days when in portait mode.
     */
    var visibleDaysInPortraitMode: Int {
        get {
            return Int(self.dayScrollView.visibleDaysInPortraitMode)
        }
        set(days) {
            self.dayScrollView.visibleDaysInPortraitMode = CGFloat(days)
        }
    }

    /**
     Number of visible days when in landscape mode.
     */
    @objc var visibleDaysInLandscapeMode: Int {
        get {
            return Int(self.dayScrollView.visibleDaysInLandscapeMode)
        }
        set(days) {
            self.dayScrollView.visibleDaysInLandscapeMode = CGFloat(days)
        }
    }

    /**
     Amount of spacing in between day view cells when in portrait mode.
     */
    @objc var portraitDayViewSideSpacing: CGFloat {
        get {
            return self.dayScrollView.portraitDayViewHorizontalSpacing
        }
        set(width) {
            self.dayScrollView.portraitDayViewHorizontalSpacing = width
        }
    }

    /**
     Amount of spacing in between day view cells when in landscape mode.
     */
    @objc var landscapeDayViewSideSpacing: CGFloat {
        get {
            return self.dayScrollView.landscapeDayViewHorizontalSpacing
        }
        set(width) {
            self.dayScrollView.landscapeDayViewHorizontalSpacing = width
        }
    }

    /**
     Amount of spacing above and below day view cells when in portrait mode.
     */
    @objc var portraitDayViewVerticalSpacing: CGFloat {
        get {
            return self.dayScrollView.portraitDayViewVerticalSpacing
        }
        set(height) {
            self.dayScrollView.portraitDayViewVerticalSpacing = height
        }
    }

    /**
     Amount of spacing above and below day view cells when in landscape mode.
     */
    @objc var landscapeDayViewVerticalSpacing: CGFloat {
        get {
            return self.dayScrollView.landscapeDayViewVerticalSpacing
        }
        set(height) {
            self.dayScrollView.landscapeDayViewVerticalSpacing = height
        }
    }

    /**
     Height for the day view cells. This is the initial height for zoom scale = 1.0.
     */
    @objc var dayViewCellHeight: CGFloat {
        get {
            return self.dayScrollView.initialDayViewCellHeight
        }
        set(height) {
            self.dayScrollView.initialDayViewCellHeight = height
        }
    }

    /**
     Font used for all event labels contained in the day view cells.
     */
    @objc var eventLabelFont: UIFont {
        get {
            return self.dayScrollView.eventLabelFont
        }
        set(font) {
            self.dayScrollView.eventLabelFont = font
        }
    }

    /**
     Thin font used for all event labels contained in the day view cells.
     */
    @objc var eventLabelInfoFont: UIFont {
        get {
            return self.dayScrollView.eventLabelInfoFont
        }
        set(font) {
            self.dayScrollView.eventLabelInfoFont = font
        }
    }

    /**
     Text color for all event labels contained in the day view cells.
     */
    @objc var eventLabelTextColor: UIColor {
        get {
            return self.dayScrollView.eventLabelTextColor
        }
        set(color) {
            self.dayScrollView.eventLabelTextColor = color
        }
    }

    /**
     Minimum percentage that event label text will be resized to if label is too small.
     */
    @available(*, deprecated, message: "This functionality has been removed")
    @objc var eventLabelMinimumFontSize: CGFloat { CGFloat(0) }

    /**
     Sets whether event label font resizing is enabled or not.
     */
    @available(*, deprecated, message: "This functionality has been removed")
    @objc var eventLabelFontResizingEnabled: Bool { false }

    /**
     Horizontal padding of the text within event labels.
     */
    @objc var eventLabelHorizontalTextPadding: CGFloat {
        get {
            return self.dayScrollView.eventLabelHorizontalTextPadding
        }
        set(padding) {
            self.dayScrollView.eventLabelHorizontalTextPadding = padding
        }
    }

    /**
     Vertical padding of the text within event labels.
     */
    @objc var eventLabelVerticalTextPadding: CGFloat {
        get {
            return self.dayScrollView.eventLabelVerticalTextPadding
        }
        set(padding) {
            self.dayScrollView.eventLabelVerticalTextPadding = padding
        }
    }

    /**
     The text shown inside the preview event.
     */
    @objc var previewEventText: String {
        get {
            return self.dayScrollView.previewEventText
        }
        set(text) {
            self.dayScrollView.previewEventText = text
        }
    }

    /**
     The color of the preview event.
     */
    @objc var previewEventColor: UIColor {
        get {
            return self.dayScrollView.previewEventColor
        }
        set(color) {
            self.dayScrollView.previewEventColor = color
        }
    }

    /**
     Height of the preview event in hours.
     */
    @objc var previewEventHeightInHours: Double {
        get {
            return self.dayScrollView.previewEventHeightInHours
        }
        set(height) {
            self.dayScrollView.previewEventHeightInHours = height
        }
    }

    /**
     The number of minutes the preview event will snap to. Ex: 15.0 will snap preview event to nearest 15 minutes.
     */
    @objc var previewEventPrecisionInMinutes: Double {
        get {
            return self.dayScrollView.previewEventPrecisionInMinutes
        }
        set(mins) {
            self.dayScrollView.previewEventPrecisionInMinutes = mins
        }
    }

    /**
     When enabled a preview event will be displayed on a long press.
     */
    @objc var showPreviewOnLongPress: Bool {
        get {
            return self.dayScrollView.showPreviewOnLongPress
        }
        set(show) {
            self.dayScrollView.showPreviewOnLongPress = show
        }
    }

    /**
     Default color of the day view cells. These are all days that are not weekends and not passed.
     */
    @objc var defaultDayViewColor: UIColor {
        get {
            return self.dayScrollView.defaultDayViewColor
        }
        set(color) {
            self.dayScrollView.defaultDayViewColor = color
        }
    }

    /**
     Color for all day view cells that are weekend days.
     */
    @objc var weekendDayViewColor: UIColor {
        get {
            return self.dayScrollView.weekendDayViewColor
        }
        set(color) {
            self.dayScrollView.weekendDayViewColor = color
        }
    }

    /**
     Color for all day view cells that are passed days and not weekends.
     */
    @objc var passedDayViewColor: UIColor {
        get {
            return self.dayScrollView.passedDayViewColor
        }
        set(color) {
            self.dayScrollView.passedDayViewColor = color
        }
    }

    /**
     Color for all day view cells that are passed weekend days.
     */
    @objc var passedWeekendDayViewColor: UIColor {
        get {
            return self.dayScrollView.passedWeekendDayViewColor
        }
        set(color) {
            self.dayScrollView.passedWeekendDayViewColor = color
        }
    }

    /**
     Color for today's view cell.
     */
    @objc var todayViewColor: UIColor {
        get {
            return self.dayScrollView.todayViewColor
        }
        set(color) {
            self.dayScrollView.todayViewColor = color
        }
    }

    /**
     Color of the current hour indicator.
     */
    @objc var dayViewHourIndicatorColor: UIColor {
        get {
            return self.dayScrollView.hourIndicatorColor
        }
        set(color) {
            self.dayScrollView.hourIndicatorColor = color
        }
    }

    /**
     Thickness (or height) of the current hour indicator.
     */
    @objc var dayViewHourIndicatorThickness: CGFloat {
        get {
            return self.dayScrollView.hourIndicatorThickness
        }
        set(thickness) {
            self.dayScrollView.hourIndicatorThickness = thickness
        }
    }

    /**
     Color of the main hour separators in the day view cells. Main separators are full lines and not dashed.
     */
    @objc var dayViewMainSeparatorColor: UIColor {
        get {
            return self.dayScrollView.mainSeparatorColor
        }
        set(color) {
            self.dayScrollView.mainSeparatorColor = color
        }
    }

    /**
     Thickness of the main hour separators in the day view cells. Main separators are full lines and not dashed.
     */
    @objc var dayViewMainSeparatorThickness: CGFloat {
        get {
            return self.dayScrollView.mainSeparatorThickness
        }
        set(thickness) {
            self.dayScrollView.mainSeparatorThickness = thickness
        }
    }

    /**
     Color of the dashed/dotted hour separators in the day view cells.
     */
    @objc var dayViewDashedSeparatorColor: UIColor {
        get {
            return self.dayScrollView.dashedSeparatorColor
        }
        set(color) {
            self.dayScrollView.dashedSeparatorColor = color
        }
    }

    /**
     Thickness of the dashed/dotted hour separators in the day view cells.
     */
    @objc var dayViewDashedSeparatorThickness: CGFloat {
        get {
            return self.dayScrollView.dashedSeparatorThickness
        }
        set(thickness) {
            self.dayScrollView.dashedSeparatorThickness = thickness
        }
    }

    /**
     Sets the pattern for the dashed/dotted separators. Requires an array of NSNumbers.
     Example 1: [10, 5] will provide a pattern of 10 points drawn, 5 points empty, repeated.
     Example 2: [3, 4, 9, 2] will provide a pattern of 4 points drawn, 4 points empty, 9 points
     drawn, 2 points empty.

     See Apple API for additional information on pattern drawing.
     https://developer.apple.com/documentation/quartzcore/cashapelayer/1521921-linedashpattern
     */
    @objc var dayViewDashedSeparatorPattern: [NSNumber] {
        get {
            return self.dayScrollView.dashedSeparatorPattern
        }
        set(pattern) {
            self.dayScrollView.dashedSeparatorPattern = pattern
        }
    }

    /**
     The minimum zoom scale to which the weekview can be zoomed. Ex. 0.5 means that the weekview
     can be zoomed to half the original given hourHeight.
     */
    @objc var minimumZoomScale: CGFloat {
        get {
            return self.dayScrollView.zoomScaleMin
        }
        set(scale) {
            self.dayScrollView.zoomScaleMin = scale
        }
    }

    /**
     The maximum zoom scale to which the weekview can be zoomed. Ex. 2.0 means that the weekview
     can be zoomed to double the original given hourHeight.
     */
    @objc var maximumZoomScale: CGFloat {
        get {
            return self.dayScrollView.zoomScaleMax
        }
        set(scale) {
            self.dayScrollView.zoomScaleMax = scale
        }
    }

    /**
     The current zoom scale to which the weekview will be zoomed. Ex. 0.5 means that the weekview
     will be zoomed to half the original given hourHeight.
     */
    @objc var currentZoomScale: CGFloat {
        get {
            return self.dayScrollView.zoomScaleCurrent
        }
        set(scale) {
            guard currentZoomScale != scale else {
                return
            }
            self.dayScrollView.zoomScaleCurrent = scale
            switch self.zoomOffsetPreservation {
            case .center:
                self.dayScrollView.centerOffset = self.dayScrollView.centerOffset
            case .top:
                self.dayScrollView.topOffset = self.dayScrollView.topOffset
            case .bottom:
                self.dayScrollView.bottomOffset = self.dayScrollView.bottomOffset
            case .reset:
                self.dayScrollView.showNow()
            case .none:
                ()
            }

        }
    }

    /**
     A callback whose return will determine the style of the event layer
     */
    var eventStyleCallback: EventStlyeCallback? {
        get {
            self.dayScrollView.eventStyleCallback
        }
        set (callback) {
            self.dayScrollView.eventStyleCallback = callback
        }
    }

    /**
     Sensitivity for horizontal scrolling. A higher number will multiply input velocity
     more and thus result in more cells being skipped when scrolling.
     */
    @objc var velocityOffsetMultiplier: CGFloat {
        get {
            return self.dayScrollView.velocityOffsetMultiplier
        }
        set(multiplier) {
            self.dayScrollView.velocityOffsetMultiplier = multiplier
        }
    }
}
