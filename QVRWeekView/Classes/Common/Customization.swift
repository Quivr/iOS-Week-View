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
            return dayScrollView.layoutVariables.defaultTopBarHeight
        }
        set(height) {
            dayScrollView.layoutVariables.defaultTopBarHeight = height
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
     Color of the side bar containing hour labels.
     */
    public var sideBarColor: UIColor {
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
    public var dayLabelTextColor: UIColor {
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
    public var dayLabelTodayTextColor: UIColor {
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
    public var dayLabelMinimumFontSize: CGFloat {
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
    public var dayLabelShortDateFormat: String {
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
    public var dayLabelNormalDateFormat: String {
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
    public var dayLabelLongDateFormat: String {
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
    public var dayLabelDateLocaleIdentifier: String {
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
    public var hourLabelFont: UIFont {
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
    public var hourLabelTextColor: UIColor {
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
    public var hourLabelMinimumFontSize: CGFloat {
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
    public var hourLabelDateFormat: String {
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
    public var allDayEventHeight: CGFloat {
        get {
            return dayScrollView.layoutVariables.allDayEventHeight
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
            return dayScrollView.layoutVariables.allDayEventVerticalSpacing
        }
        set(height) {
            dayScrollView.setAllDayEventVerticalSpacing(to: height)
        }
    }

    /**
     Spread all day events on x axis, if not true than spread will be made on y axis.
     */
    public var allDayEventsSpreadOnX: Bool {
        get {
            return dayScrollView.layoutVariables.allDayEventsSpreadOnX
        }
        set(onX) {
            self.dayScrollView.setAllDayEventsSpreadOnX(to: onX)
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
            return Int(dayScrollView.layoutVariables.portraitVisibleDays)
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
            return Int(dayScrollView.layoutVariables.landscapeVisibleDays)
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
            return TextVariables.eventLabelFont
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
            return TextVariables.eventLabelInfoFont
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
            return TextVariables.eventLabelTextColor
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
            return TextVariables.eventLabelMinimumFontSize
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
            return TextVariables.eventLabelFontResizingEnabled
        }
        set(bool) {
            self.dayScrollView.setEventLabelFontResizingEnabled(to: bool)
        }
    }

    /**
     Horizontal padding of the text within event labels.
     */
    public var eventLabelHorizontalTextPadding: CGFloat {
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
    public var eventLabelVerticalTextPadding: CGFloat {
        get {
            return TextVariables.eventLabelVerticalTextPadding
        }
        set(padding) {
            self.dayScrollView.setEventLabelVerticalTextPadding(to: padding)
        }
    }

    /**
     Should time of events be shown.
     */
    public var eventShowTimeOfEvent: Bool {
        get {
            return TextVariables.eventShowTimeOfEvent
        }
        set(showTime) {
            self.dayScrollView.setEventShowTimeOfEvent(to: showTime)
        }
    }

    /**
     Should all event's data be in one line
     */
    public var eventsDataInOneLine: Bool {
        get {
            return TextVariables.eventsDataInOneLine
        }
        set(dataInOneLine) {
            self.dayScrollView.setEventsDataInOneLine(to: dataInOneLine)
        }
    }

    /**
     Set's smalles heigh for event.
     */
    public var eventsSmallestHeight: CGFloat {
        get {
            return TextVariables.eventsSmallestHeight
        }
        set(height) {
            self.dayScrollView.setEventsSmallestHeight(to: height)
        }
    }

    /**
     The text shown inside the previw event.
     */
    public var previewEventText: String {
        get {
            return dayScrollView.layoutVariables.previewEventText
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
            return dayScrollView.layoutVariables.previewEventColor
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
            return dayScrollView.layoutVariables.previewEventHeightInHours
        }
        set(height) {
            self.dayScrollView.setPreviewEventHeightInHours(to: height)
        }
    }

    /**
     The number of minutes the preview event will snap to. Ex: 15.0 will snap preview event to nearest 15 minutes.
     */
    public var previewEventPrecisionInMinutes: Double {
        get {
            return dayScrollView.layoutVariables.previewEventPrecisionInMinutes
        }
        set(mins) {
            self.dayScrollView.setPreviewEventPrecisionInMinutes(to: mins)
        }
    }

    /**
     Show preview on long press.
     */
    public var showPreviewOnLongPress: Bool {
        get {
            return dayScrollView.layoutVariables.showPreviewOnLongPress
        }
        set(show) {
            self.dayScrollView.setShowPreviewOnLongPress(to: show)
        }
    }

    /**
     Default color of the day view cells. These are all days that are not weekends and not passed.
     */
    public var defaultDayViewColor: UIColor {
        get {
            return dayScrollView.layoutVariables.defaultDayViewColor
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
    public var weekendDayViewColor: UIColor {
        get {
            return dayScrollView.layoutVariables.weekendDayViewColor
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
            return dayScrollView.layoutVariables.passedDayViewColor
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
            return dayScrollView.layoutVariables.passedWeekendDayViewColor
        }
        set(color) {
            self.dayScrollView.setPassedWeekendDayViewColor(to: color)
        }
    }

    /**
     Color for today's view cell.
     */
    public var todayViewColor: UIColor {
        get {
            return dayScrollView.layoutVariables.todayViewColor
        }
        set(color) {
            self.dayScrollView.setTodayViewColor(to: color)
        }
    }

    /**
     Color of the hour indicator.
     */
    public var dayViewHourIndicatorColor: UIColor {
        get {
            return dayScrollView.layoutVariables.hourIndicatorColor
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
            return dayScrollView.layoutVariables.hourIndicatorThickness
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
            return dayScrollView.layoutVariables.mainSeparatorColor
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
            return dayScrollView.layoutVariables.mainSeparatorThickness
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
            return dayScrollView.layoutVariables.dashedSeparatorColor
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
            return dayScrollView.layoutVariables.dashedSeparatorThickness
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
            return dayScrollView.layoutVariables.dashedSeparatorPattern
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
            return dayScrollView.layoutVariables.dayViewCellHeight
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
            return dayScrollView.layoutVariables.portraitDayViewHorizontalSpacing
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
            return dayScrollView.layoutVariables.landscapeDayViewHorizontalSpacing
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
            return dayScrollView.layoutVariables.portraitDayViewVerticalSpacing
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
            return dayScrollView.layoutVariables.landscapeDayViewVerticalSpacing
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
    public var minimumZoomScale: CGFloat {
        get {
            return dayScrollView.layoutVariables.minimumZoomScale
        }
        set(scale) {
            self.dayScrollView.setMinimumZoomScale(to: scale)
        }
    }

    /**
     The maximum zoom scale to which the weekview can be zoomed. Ex. 2.0 means that the weekview
     can be zoomed to double the original given hourHeight.
     */
    public var maximumZoomScale: CGFloat {
        get {
            return dayScrollView.layoutVariables.minimumZoomScale
        }
        set(scale) {
            self.dayScrollView.setMaximumZoomScale(to: scale)
        }
    }

    /**
     Sensitivity for horizontal scrolling. A higher number will multiply input velocity
     more and thus result in more cells being skipped when scrolling.
     */
    public var velocityOffsetMultiplier: CGFloat {
        get {
            return dayScrollView.layoutVariables.velocityOffsetMultiplier
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

    private static var adjustedDefaultTopBarHeightValues = [ObjectIdentifier: CGFloat]()

    // Default height of the top bar
    fileprivate(set) var defaultTopBarHeight: CGFloat {
        get { return LayoutVariables.adjustedDefaultTopBarHeightValues[ObjectIdentifier(self)] ?? LayoutDefaults.defaultTopBarHeight }
        set { LayoutVariables.adjustedDefaultTopBarHeightValues[ObjectIdentifier(self)] = newValue }
    }

}
