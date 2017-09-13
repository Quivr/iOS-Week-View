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

    // MARK: - WEEKVIEW CUSTOMIZATION -

    /**
     Background color of main scrollview.
     */
    public var mainBackgroundColor: UIColor {
        get {
            return self.mainView.backgroundColor!
        }
        set(color) {
            self.mainView.backgroundColor = color
            self.sideBarView.backgroundColor = color
        }
    }

    /**
     Default height of the top bar
     */
    public var defaultTopBarHeight: CGFloat {
        get {
            return LayoutVariables.defaultTopBarHeight
        }
        set(height) {
            LayoutVariables.defaultTopBarHeight = height
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Background color of top bar containing day labels.
     */
    public var topBarColor: UIColor {
        get {
            return self.topBarView.backgroundColor!
        }
        set(color) {
            self.topLeftBufferView.backgroundColor = color
            self.topBarView.backgroundColor = color
        }
    }

    /**
     Width of the side bar containing hour labels.
     */
    public var sideBarWidth: CGFloat {
        get {
            return self.sideBarView.frame.width
        }
        set(width) {
            self.sideBarWidthConstraint.constant = width
            self.topLeftBufferWidthConstraint.constant = width
        }
    }

    /**
     Font for all day labels contained in the top bar.
     */
    public var dayLabelDefaultFont: UIFont {
        get {
            return FontVariables.dayLabelDefaultFont
        }
        set(font) {
            FontVariables.dayLabelDefaultFont = font
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Text color for all day labels contained in the top bar.
     */
    public var dayLabelTextColor: UIColor {
        get {
            return FontVariables.dayLabelTextColor
        }
        set(color) {
            FontVariables.dayLabelTextColor = color
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Text color for today day label contained in the top bar.
     */
    public var dayLabelTodayTextColor: UIColor {
        get {
            return FontVariables.dayLabelTodayTextColor
        }
        set(color) {
            FontVariables.dayLabelTodayTextColor = color
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Minimum font size that day label text will be resized to if label is too small.
     */
    public var dayLabelMinimumFontSize: CGFloat {
        get {
            return FontVariables.dayLabelMinimumFontSize
        }
        set(scale) {
            FontVariables.dayLabelMinimumFontSize = scale
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Date formats for day labels.
     See reference of date formats at: http://nsdateformatter.com/
     */
    public var dayLabelDateFormats: [TextMode: String] {
        get {
            return FontVariables.dayLabelDateFormats
        }
        set(formats) {
            FontVariables.dayLabelDateFormats = formats
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Font for all hour labels contained in the side bar.
     */
    public var hourLabelFont: UIFont {
        get {
            return FontVariables.hourLabelFont
        }
        set(font) {
            FontVariables.hourLabelFont = font
            updateHourSideBarView()
        }
    }

    /**
     Text color for all hour labels contained in the side bar.
     */
    public var hourLabelTextColor: UIColor {
        get {
            return FontVariables.hourLabelTextColor
        }
        set(color) {
            FontVariables.hourLabelTextColor = color
            updateHourSideBarView()
        }
    }

    /**
     Minimum percentage that hour label text will be resized to if label is too small.
     */
    public var hourLabelMinimumFontSize: CGFloat {
        get {
            return FontVariables.hourLabelMinimumFontSize
        }
        set(scale) {
            FontVariables.hourLabelMinimumFontSize = scale
            updateHourSideBarView()
        }
    }

    /**
     Format of all hour labels.
     */
    public var hourLabelDateFormat: String {
        get {
            return FontVariables.hourLabelDateFormat
        }
        set(format) {
            FontVariables.hourLabelDateFormat = format
            updateHourSideBarView()
        }
    }

    /**
     Height of all day labels.
     */
    public var allDayEventHeight: CGFloat {
        get {
            return LayoutVariables.allDayEventHeight
        }
        set(height) {
            self.dayScrollView.setAllDayEventHeight(to: height)
        }
    }

    /**
     Height of all day labels.
     */
    public var allDayEventVerticalSpacing: CGFloat {
        get {
            return LayoutVariables.allDayEventVerticalSpacing
        }
        set(height) {
            dayScrollView.setAllDayEventVerticalSpacing(to: height)
        }
    }

    /**
     Helper function for hour label customization.
     */
    private func updateHourSideBarView() {
        for view in self.sideBarView.subviews {
            if let hourSideBarView = view as? HourSideBarView {
                hourSideBarView.layoutIfNeeded()
                hourSideBarView.updateLabels()
            }
        }
    }

    // MARK: - DAYSCROLLVIEW CUSTOMIZATION -

    /**
     Number of visible days when in portait mode.
     */
    public var visibleDaysInPortraitMode: Int {
        get {
            return Int(LayoutVariables.portraitVisibleDays)
        }
        set(days) {
            if self.dayScrollView.setVisiblePortraitDays(to: CGFloat(days)) {
                updateVisibleLabelsAndMainConstraints()
            }
        }
    }

    /**
     Number of visible days when in landscape mode.
     */
    public var visibleDaysInLandscapeMode: Int {
        get {
            return Int(LayoutVariables.landscapeVisibleDays)
        }
        set(days) {
            if self.dayScrollView.setVisibleLandscapeDays(to: CGFloat(days)) {
                updateVisibleLabelsAndMainConstraints()
            }
        }
    }

    /**
     Font used for all event labels contained in the day view cells.
     */
    public var eventLabelFont: UIFont {
        get {
            return FontVariables.eventLabelFont
        }
        set(font) {
            self.dayScrollView.setEventLabelFont(to: font)
        }
    }

    /**
    Thin font used for all event labels contained in the day view cells.
    */
    public var eventLabelInfoFont: UIFont {
        get {
            return FontVariables.eventLabelInfoFont
        }
        set(font) {
            self.dayScrollView.setEventLabelInfoFont(to: font)
        }
    }

    /**
     Text color for all event labels contained in the day view cells.
     */
    public var eventLabelTextColor: UIColor {
        get {
            return FontVariables.eventLabelTextColor
        }
        set(color) {
            self.dayScrollView.setEventLabelTextColor(to: color)
        }
    }

    /**
     Minimum percentage that event label text will be resized to if label is too small.
     */
    public var eventLabelMinimumFontSize: CGFloat {
        get {
            return FontVariables.eventLabelMinimumFontSize
        }
        set(scale) {
            self.dayScrollView.setEventLabelMinimumFontSize(to: scale)
        }
    }

    /**
     Sets whether event label font resizing is enabled or not.
     */
    public var eventLabelFontResizingEnabled: Bool {
        get {
            return FontVariables.eventLabelFontResizingEnabled
        }
        set(bool) {
            self.dayScrollView.setEventLabelFontResizingEnabled(to: bool)
        }
    }

    /**
     The text shown inside the previw event.
     */
    public var previewEventText: String {
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
    public var previewEventColor: UIColor {
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
    public var previewEventHeightInHours: Double {
        get {
            return LayoutVariables.previewEventHeightInHours
        }
        set(height) {
            self.dayScrollView.setPreviewEventHeightInHours(to: height)
        }
    }

    /**
     Default color of the day view cells. These are all days that are not weekends and not passed.
     */
    public var defaultDayViewColor: UIColor {
        get {
            return LayoutVariables.defaultDayViewColor
        }
        set(color) {
            self.dayScrollView.setDefaultDayViewColor(to: color)
        }
    }

    /**
     Color for all day view cells that are weekend days.
     */
    public var weekendDayViewColor: UIColor {
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
    public var passedDayViewColor: UIColor {
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
    public var passedWeekendDayViewColor: UIColor {
        get {
            return LayoutVariables.passedWeekendDayViewColor
        }
        set(color) {
            self.dayScrollView.setPassedWeekendDayViewColor(to: color)
        }
    }

    /**
     Color of the hour indicator.
     */
    public var dayViewHourIndicatorColor: UIColor {
        get {
            return LayoutVariables.hourIndicatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewHourIndicatorColor(to: color)
        }
    }

    /**
     Thickness (or height) of the hour indicator.
     */
    public var dayViewHourIndicatorThickness: CGFloat {
        get {
            return LayoutVariables.hourIndicatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewHourIndicatorThickness(to: thickness)
        }
    }

    /**
     Color of the main separators in the day view cells. Main separators are full lines and not dashed.
     */
    public var dayViewMainSeparatorColor: UIColor {
        get {
            return LayoutVariables.mainSeparatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewMainSeparatorColor(to: color)
        }
    }

    /**
     Thickness of the main separators in the day view cells. Main separators are full lines and not dashed.
     */
    public var dayViewMainSeparatorThickness: CGFloat {
        get {
            return LayoutVariables.mainSeparatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewMainSeparatorThickness(to: thickness)
        }
    }

    /**
     Color of the dashed/dotted separators in the day view cells.
     */
    public var dayViewDashedSeparatorColor: UIColor {
        get {
            return LayoutVariables.dashedSeparatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewDashedSeparatorColor(to: color)
        }
    }

    /**
     Thickness of the dashed/dotted separators in the day view cells.
     */
    public var dayViewDashedSeparatorThickness: CGFloat {
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
    public var dayViewDashedSeparatorPattern: [NSNumber] {
        get {
            return LayoutVariables.dashedSeparatorPattern
        }
        set(pattern) {
            self.dayScrollView.setDayViewDashedSeparatorPattern(to: pattern)
        }
    }

    /**
     Height for the day view cells. This is the initial height for zoom scale = 1.0.
     */
    public var dayViewCellHeight: CGFloat {
        get {
            return LayoutVariables.dayViewCellHeight
        }
        set(height) {
            self.dayScrollView.setInitialVisibleDayViewCellHeight(to: height)
        }
    }

    /**
     Amount of spacing in between day view cells when in portrait mode.
     */
    public var portraitDayViewSideSpacing: CGFloat {
        get {
            return LayoutVariables.portraitDayViewHorizontalSpacing
        }
        set(width) {
            if self.dayScrollView.setPortraitDayViewHorizontalSpacing(to: width) {
                updateVisibleLabelsAndMainConstraints()
            }
        }
    }

    /**
     Amount of spacing in between day view cells when in landscape mode.
     */
    public var landscapeDayViewSideSpacing: CGFloat {
        get {
            return LayoutVariables.landscapeDayViewHorizontalSpacing
        }
        set(width) {
            if self.dayScrollView.setLandscapeDayViewHorizontalSpacing(to: width) {
                updateVisibleLabelsAndMainConstraints()
            }
        }
    }

    /**
     Amount of spacing above and below day view cells when in portrait mode.
     */
    public var portraitDayViewVerticalSpacing: CGFloat {
        get {
            return LayoutVariables.portraitDayViewVerticalSpacing
        }
        set(height) {
            if self.dayScrollView.setPortraitDayViewVerticalSpacing(to: height) {
                updateVisibleLabelsAndMainConstraints()
            }
        }
    }

    /**
     Amount of spacing above and below day view cells when in landscape mode.
     */
    public var landscapeDayViewVerticalSpacing: CGFloat {
        get {
            return LayoutVariables.landscapeDayViewVerticalSpacing
        }
        set(height) {
            if self.dayScrollView.setLandscapeDayViewVerticalSpacing(to: height) {
                updateVisibleLabelsAndMainConstraints()
            }
        }
    }

    /**
     Sensitivity for horizontal scrolling. A higher number will multiply input velocity
     more and thus result in more cells being skipped when scrolling.
     */
    public var velocityOffsetMultiplier: CGFloat {
        get {
            return LayoutVariables.velocityOffsetMultiplier
        }
        set(multiplier) {
            self.dayScrollView.setVelocityOffsetMultiplier(to: multiplier)
        }
    }
}

// Customization extension for FontVariables.
extension FontVariables {

    // Default font for all day labels
    fileprivate(set) static var dayLabelDefaultFont = LayoutDefaults.dayLabelFont {
        didSet {
            updateDayLabelCurrentFont()
        }
    }
    // Text color for all day labels
    fileprivate(set) static var dayLabelTextColor = LayoutDefaults.dayLabelTextColor
    // Text color for today day labels
    fileprivate(set) static var dayLabelTodayTextColor = LayoutDefaults.dayLabelTodayTextColor
    // Minimum font for all day labels
    fileprivate(set) static var dayLabelMinimumFontSize = LayoutDefaults.dayLabelMinimumFontSize
    // Date formats for day labels
    fileprivate(set) static var dayLabelDateFormats: [TextMode: String] = LayoutDefaults.dayLabelDateFormats

    // Font for all hour labels
    fileprivate(set) static var hourLabelFont = LayoutDefaults.hourLabelFont {
        didSet {
            updateHourMinScale()
        }
    }
    // Text color for all hour labels
    fileprivate(set) static var hourLabelTextColor = LayoutDefaults.hourLabelTextColor
    // Minimum font size for all hour labels
    fileprivate(set) static var hourLabelMinimumFontSize = LayoutDefaults.hourLabelMinimumFontSize {
        didSet {
            updateHourMinScale()
        }
    }
    // Minimum scale for all hour labels
    private(set) static var hourLabelMinimumScale = LayoutDefaults.hourLabelMinimumFontSize / LayoutDefaults.hourLabelFont.pointSize
    // Default format for all hour labels
    fileprivate(set) static var hourLabelDateFormat = LayoutDefaults.hourLabelDateFormat

    // Method updates the minimum hour scale
    private static func updateHourMinScale () {
        hourLabelMinimumScale = hourLabelMinimumFontSize / hourLabelFont.pointSize
    }

}

// Customization extension for LayoutVariables
extension LayoutVariables {

    // Default height of the top bar
    fileprivate(set) static var defaultTopBarHeight = LayoutDefaults.defaultTopBarHeight

}
