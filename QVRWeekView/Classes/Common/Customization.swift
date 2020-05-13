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
            return TextVariables.eventLabelFont
        }
        set(font) {
            self.dayScrollView.setEventLabelFont(to: font)
        }
    }

    /**
     Thin font used for all event labels contained in the day view cells.
     */
    @objc var eventLabelInfoFont: UIFont {
        get {
            return TextVariables.eventLabelInfoFont
        }
        set(font) {
            self.dayScrollView.setEventLabelInfoFont(to: font)
        }
    }

    /**
     Text color for all event labels contained in the day view cells.
     */
    @objc var eventLabelTextColor: UIColor {
        get {
            return TextVariables.eventLabelTextColor
        }
        set(color) {
            self.dayScrollView.setEventLabelTextColor(to: color)
        }
    }

    /**
     Minimum percentage that event label text will be resized to if label is too small.
     */
    @objc var eventLabelMinimumFontSize: CGFloat {
        get {
            return TextVariables.eventLabelMinimumFontSize
        }
        set(scale) {
            self.dayScrollView.setEventLabelMinimumFontSize(to: scale)
        }
    }

    /**
     Sets whether event label font resizing is enabled or not.
     */
    @available(*, deprecated, message: "This functionality has been removed")
    @objc var eventLabelFontResizingEnabled: Bool {
        get {
            return TextVariables.eventLabelFontResizingEnabled
        }
        set(bool) {
            self.dayScrollView.setEventLabelFontResizingEnabled(to: bool)
        }
    }

    /**
     Horizontal padding of the text within event labels.
     */
    @objc var eventLabelHorizontalTextPadding: CGFloat {
        get {
            return TextVariables.eventLabelHorizontalTextPadding
        }
        set(padding) {
            self.dayScrollView.setEventLabelHorizontalTextPadding(to: padding)
        }
    }

    /**
     Vertical padding of the text within event labels.
     */
    @objc var eventLabelVerticalTextPadding: CGFloat {
        get {
            return TextVariables.eventLabelVerticalTextPadding
        }
        set(padding) {
            self.dayScrollView.setEventLabelVerticalTextPadding(to: padding)
        }
    }

    /**
     The text shown inside the preview event.
     */
    @objc var previewEventText: String {
        get {
            return LayoutVariables.previewEventText
        }
        set(text) {
            self.dayScrollView.setPreviewEventText(to: text)
        }
    }

    /**
     The color of the preview event.
     */
    @objc var previewEventColor: UIColor {
        get {
            return LayoutVariables.previewEventColor
        }
        set(color) {
            self.dayScrollView.setPreviewEventColor(to: color)
        }
    }

    /**
     Height of the preview event in hours.
     */
    @objc var previewEventHeightInHours: Double {
        get {
            return LayoutVariables.previewEventHeightInHours
        }
        set(height) {
            self.dayScrollView.setPreviewEventHeightInHours(to: height)
        }
    }

    /**
     The number of minutes the preview event will snap to. Ex: 15.0 will snap preview event to nearest 15 minutes.
     */
    @objc var previewEventPrecisionInMinutes: Double {
        get {
            return LayoutVariables.previewEventPrecisionInMinutes
        }
        set(mins) {
            self.dayScrollView.setPreviewEventPrecisionInMinutes(to: mins)
        }
    }

    /**
     When enabled a preview event will be displayed on a long press.
     */
    @objc var showPreviewOnLongPress: Bool {
        get {
            return LayoutVariables.showPreviewOnLongPress
        }
        set(show) {
            self.dayScrollView.setShowPreviewOnLongPress(to: show)
        }
    }

    /**
     Default color of the day view cells. These are all days that are not weekends and not passed.
     */
    @objc var defaultDayViewColor: UIColor {
        get {
            return LayoutVariables.defaultDayViewColor
        }
        set(color) {
            if self.todayViewColor == self.defaultDayViewColor {
                self.dayScrollView.setTodayViewColor(to: color)
            }
            self.dayScrollView.setDefaultDayViewColor(to: color)
        }
    }

    /**
     Color for all day view cells that are weekend days.
     */
    @objc var weekendDayViewColor: UIColor {
        get {
            return LayoutVariables.weekendDayViewColor
        }
        set(color) {
            self.dayScrollView.setWeekendDayViewColor(to: color)
        }
    }

    /**
     Color for all day view cells that are passed days and not weekends.
     */
    @objc var passedDayViewColor: UIColor {
        get {
            return LayoutVariables.passedDayViewColor
        }
        set(color) {
            self.dayScrollView.setPassedDayViewColor(to: color)
        }
    }

    /**
     Color for all day view cells that are passed weekend days.
     */
    @objc var passedWeekendDayViewColor: UIColor {
        get {
            return LayoutVariables.passedWeekendDayViewColor
        }
        set(color) {
            self.dayScrollView.setPassedWeekendDayViewColor(to: color)
        }
    }

    /**
     Color for today's view cell.
     */
    @objc var todayViewColor: UIColor {
        get {
            return LayoutVariables.todayViewColor
        }
        set(color) {
            self.dayScrollView.setTodayViewColor(to: color)
        }
    }

    /**
     Color of the current hour indicator.
     */
    @objc var dayViewHourIndicatorColor: UIColor {
        get {
            return LayoutVariables.hourIndicatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewHourIndicatorColor(to: color)
        }
    }

    /**
     Thickness (or height) of the current hour indicator.
     */
    @objc var dayViewHourIndicatorThickness: CGFloat {
        get {
            return LayoutVariables.hourIndicatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewHourIndicatorThickness(to: thickness)
        }
    }

    /**
     Color of the main hour separators in the day view cells. Main separators are full lines and not dashed.
     */
    @objc var dayViewMainSeparatorColor: UIColor {
        get {
            return LayoutVariables.mainSeparatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewMainSeparatorColor(to: color)
        }
    }

    /**
     Thickness of the main hour separators in the day view cells. Main separators are full lines and not dashed.
     */
    @objc var dayViewMainSeparatorThickness: CGFloat {
        get {
            return LayoutVariables.mainSeparatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewMainSeparatorThickness(to: thickness)
        }
    }

    /**
     Color of the dashed/dotted hour separators in the day view cells.
     */
    @objc var dayViewDashedSeparatorColor: UIColor {
        get {
            return LayoutVariables.dashedSeparatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewDashedSeparatorColor(to: color)
        }
    }

    /**
     Thickness of the dashed/dotted hour separators in the day view cells.
     */
    @objc var dayViewDashedSeparatorThickness: CGFloat {
        get {
            return LayoutVariables.dashedSeparatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewDashedSeparatorThickness(to: thickness)
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
            return LayoutVariables.dashedSeparatorPattern
        }
        set(pattern) {
            self.dayScrollView.setDayViewDashedSeparatorPattern(to: pattern)
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
