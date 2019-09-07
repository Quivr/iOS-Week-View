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
    @objc var mainBackgroundColor: UIColor {
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
    @objc var defaultTopBarHeight: CGFloat {
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
    @objc var topBarColor: UIColor {
        get {
            return self.topBarView.backgroundColor!
        }
        set(color) {
            self.topLeftBufferView.backgroundColor = color
            self.topBarView.backgroundColor = color
        }
    }

    /**
     Color of the side bar containing hour labels.
     */
    @objc var sideBarColor: UIColor {
        get {
            return self.sideBarView.backgroundColor!
        }
        set(color) {
            self.sideBarView.backgroundColor = color
        }
    }

    /**
     Width of the side bar containing hour labels.
     */
    @objc var sideBarWidth: CGFloat {
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
    @objc var dayLabelDefaultFont: UIFont {
        get {
            return TextVariables.dayLabelDefaultFont
        }
        set(font) {
            TextVariables.dayLabelDefaultFont = font
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Text color for all day labels contained in the top bar.
     */
    @objc var dayLabelTextColor: UIColor {
        get {
            return TextVariables.dayLabelTextColor
        }
        set(color) {
            TextVariables.dayLabelTextColor = color
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Text color for today day label contained in the top bar.
     */
    @objc var dayLabelTodayTextColor: UIColor {
        get {
            return TextVariables.dayLabelTodayTextColor
        }
        set(color) {
            TextVariables.dayLabelTodayTextColor = color
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Minimum font size that day label text will be resized to if label is too small.
     */
    @objc var dayLabelMinimumFontSize: CGFloat {
        get {
            return TextVariables.dayLabelMinimumFontSize
        }
        set(scale) {
            TextVariables.dayLabelMinimumFontSize = scale
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Short date format for day labels.
     See reference of date formats at: http://nsdateformatter.com/
     */
    @objc var dayLabelShortDateFormat: String {
        get {
            return TextVariables.dayLabelDateFormats[.small]!
        }
        set(format) {
            TextVariables.dayLabelDateFormats[.small] = format
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Normal date format for day labels.
     See reference of date formats at: http://nsdateformatter.com/
     */
    @objc var dayLabelNormalDateFormat: String {
        get {
            return TextVariables.dayLabelDateFormats[.normal]!
        }
        set(format) {
            TextVariables.dayLabelDateFormats[.normal] = format
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Long date format for day labels.
     See reference of date formats at: http://nsdateformatter.com/
     */
    @objc var dayLabelLongDateFormat: String {
        get {
            return TextVariables.dayLabelDateFormats[.large]!
        }
        set(format) {
            TextVariables.dayLabelDateFormats[.large] = format
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Locale for the day labels.
     If none is given device locale will be used.
     */
    @objc var dayLabelDateLocaleIdentifier: String {
        get {
            if let locale = TextVariables.dayLabelDateLocale {
                return locale.languageCode!
            } else {
                return NSLocale.current.languageCode!
            }
        }
        set(id) {
            TextVariables.dayLabelDateLocale = Locale(identifier: id)
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Font for all hour labels contained in the side bar.
     */
    @objc var hourLabelFont: UIFont {
        get {
            return TextVariables.hourLabelFont
        }
        set(font) {
            TextVariables.hourLabelFont = font
            updateHourSideBarView()
        }
    }

    /**
     Text color for all hour labels contained in the side bar.
     */
    @objc var hourLabelTextColor: UIColor {
        get {
            return TextVariables.hourLabelTextColor
        }
        set(color) {
            TextVariables.hourLabelTextColor = color
            updateHourSideBarView()
        }
    }

    /**
     Minimum percentage that hour label text will be resized to if label is too small.
     */
    @objc var hourLabelMinimumFontSize: CGFloat {
        get {
            return TextVariables.hourLabelMinimumFontSize
        }
        set(scale) {
            TextVariables.hourLabelMinimumFontSize = scale
            updateHourSideBarView()
        }
    }

    /**
     Format of all hour labels.
     */
    @objc var hourLabelDateFormat: String {
        get {
            return TextVariables.hourLabelDateFormat
        }
        set(format) {
            TextVariables.hourLabelDateFormat = format
            updateHourSideBarView()
        }
    }

    /**
     Height of all day labels.
     */
    @objc var allDayEventHeight: CGFloat {
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
    @objc var allDayEventVerticalSpacing: CGFloat {
        get {
            return LayoutVariables.allDayEventVerticalSpacing
        }
        set(height) {
            dayScrollView.setAllDayEventVerticalSpacing(to: height)
        }
    }

    /**
     Spread all day events on x axis, if not true than spread will be made on y axis.
     */
    @objc var allDayEventsSpreadOnX: Bool {
        get {
            return LayoutVariables.allDayEventsSpreadOnX
        }
        set(onX) {
            self.dayScrollView.setAllDayEventsSpreadOnX(to: onX)
        }
    }

    /**
     Enable this to automatically allow events to be converted to allDay events if they go from midnight to midnight. (default true)
     */
    @objc var autoConvertAllDayEvents: Bool {
        get {
            return LayoutVariables.autoConvertAllDayEvents
        }
        set(enable) {
            LayoutVariables.autoConvertAllDayEvents = enable
        }
    }

    /**
     Helper function for hour label customization.
     */
    @objc private func updateHourSideBarView() {
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
    @objc var visibleDaysInPortraitMode: Int {
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
    @objc var visibleDaysInLandscapeMode: Int {
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
     Height for the day view cells. This is the initial height for zoom scale = 1.0.
     */
    @objc var dayViewCellHeight: CGFloat {
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
    @objc var portraitDayViewSideSpacing: CGFloat {
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
    @objc var landscapeDayViewSideSpacing: CGFloat {
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
    @objc var portraitDayViewVerticalSpacing: CGFloat {
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
    @objc var landscapeDayViewVerticalSpacing: CGFloat {
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
     The minimum zoom scale to which the weekview can be zoomed. Ex. 0.5 means that the weekview
     can be zoomed to half the original given hourHeight.
     */
    @objc var minimumZoomScale: CGFloat {
        get {
            return LayoutVariables.minimumZoomScale
        }
        set(scale) {
            self.dayScrollView.setMinimumZoomScale(to: scale)
        }
    }

    /**
     The current zoom scale to which the weekview will be zoomed. Ex. 0.5 means that the weekview
     will be zoomed to half the original given hourHeight.
     */
    @objc var currentZoomScale: CGFloat {
        get {
            return LayoutVariables.zoomScale
        }
        set(scale) {
            guard currentZoomScale != scale else {
                return
            }
            switch self.zoomOffsetPreservation {
            case .center:
                let offset = self.dayScrollView.centerOffset
                self.dayScrollView.setCurrentZoomScale(to: scale)
                self.dayScrollView.centerOffset = offset
            case .top:
                let offset = self.dayScrollView.topOffset
                self.dayScrollView.setCurrentZoomScale(to: scale)
                self.dayScrollView.topOffset = offset
            case .bottom:
                let offset = self.dayScrollView.bottomOffset
                self.dayScrollView.setCurrentZoomScale(to: scale)
                self.dayScrollView.bottomOffset = offset
            case .reset:
                self.dayScrollView.setCurrentZoomScale(to: scale)
                self.dayScrollView.showNow()
            default:
                self.dayScrollView.setCurrentZoomScale(to: scale)
            }

        }
    }

    /**
     The maximum zoom scale to which the weekview can be zoomed. Ex. 2.0 means that the weekview
     can be zoomed to double the original given hourHeight.
     */
    @objc var maximumZoomScale: CGFloat {
        get {
            return LayoutVariables.minimumZoomScale
        }
        set(scale) {
            self.dayScrollView.setMaximumZoomScale(to: scale)
        }
    }

    /**
     Sensitivity for horizontal scrolling. A higher number will multiply input velocity
     more and thus result in more cells being skipped when scrolling.
     */
    @objc var velocityOffsetMultiplier: CGFloat {
        get {
            return LayoutVariables.velocityOffsetMultiplier
        }
        set(multiplier) {
            self.dayScrollView.setVelocityOffsetMultiplier(to: multiplier)
        }
    }
}

// Customization extension for FontVariables.
extension TextVariables {
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
    // Locale of day labels
    fileprivate(set) static var dayLabelDateLocale: Locale?

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

    // Automatically
    fileprivate(set) static var autoConvertAllDayEvents = true

}
