//
//  CalendarView.swift

import Foundation
import UIKit

/**
 Class of the main week view. This view can be placed anywhere and will adapt to given size. All behaviours are internal,
 and all customization can be done with public functions. No delegates have been implemented yet.
 WeekView can be used in both landscape and portrait mode.
 */
open class WeekView: UIView {

    // MARK: - OUTLETS -

    @IBOutlet var topBarView: UIView!
    @IBOutlet var topLeftBufferView: UIView!
    @IBOutlet var sideBarView: UIView!
    @IBOutlet var dayScrollView: DayScrollView!

    // MARK: - CONSTRAINTS -

    @IBOutlet var sideBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var sideBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var sideBarYPositionConstraint: NSLayoutConstraint!
    @IBOutlet var hourSideBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet var topBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var topBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var topBarXPositionConstraint: NSLayoutConstraint!
    @IBOutlet var topLeftBufferWidthConstraint: NSLayoutConstraint!
    @IBOutlet var topLeftBufferHeightConstraint: NSLayoutConstraint!

    // MARK: - PUBLIC PROPERTIES -

    // WeekView Delegate
    public weak var delegate: WeekViewDelegate?

    public var currentDay: Date {
        return dayScrollView.activeDay.dateObj
    }

    // MARK: - PRIVATE VARIABLES -

    // The actual view being displayed, all other views are subview of this mainview
    private(set) var mainView: UIView!
    // Array of visible daylabels
    private var visibleDayLabels: [DayDate: UILabel] = [:]
    // Array of visible allDayEvents
    private var visibleAllDayEvents: [DayDate: [EventData: CAShapeLayer]] = [:]
    // Array of labels not being displayed
    private var discardedDayLabels: [UILabel] = []
    // Left side buffer for top bar
    private var topBarLeftBuffer: CGFloat = 0
    // Top side buffer for side bar
    private var sideBarTopBuffer: CGFloat = 0
    // The scale of the latest pinch event
    private var lastTouchScale = CGFloat(0)

    // MARK: - CONSTRUCTORS/OVERRIDES -

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWeekView()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initWeekView()
    }

    open override func didMoveToWindow() {
        updateTimeDisplayed()
        dayScrollView.requestEvents()
    }

    private func initWeekView() {
        // Get the view layout from the nib
        setView()
        // Create pinch recognizer
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomView(_:))))
        // Create tap recognizer for top bar
        self.topBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopBar(_:))))
        // Set clipping to bounds (prevents side bar, top bar and other sub view protrusion)
        self.clipsToBounds = true
        self.topBarView.clipsToBounds = true
    }

    private func setView() {
        let bundle = Bundle(for: WeekView.self)
        let nib = UINib(nibName: NibNames.weekView, bundle: bundle)
        self.mainView = nib.instantiate(withOwner: self, options: nil).first as? UIView

        if mainView != nil {
            self.mainView!.frame = self.bounds
            self.mainView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.mainView!)
        }
        self.backgroundColor = UIColor.clear
        updateVisibleLabelsAndMainConstraints()
    }

    // MARK: - PUBLIC FUNCTIONS -

    /**
     Updates the time displayed on the calendar
     */
    public func updateTimeDisplayed() {
        let dayCollectionView = dayScrollView.dayCollectionView!
        for cell in dayCollectionView.visibleCells {
            if let dayViewCell = cell as? DayViewCell {
                dayViewCell.updateTimeView()
            }
        }
    }

    /**
     Shows the day view cell corresponding to asked day.
     */
    public func showDay(withDate date: Date) {
        dayScrollView.goToAndShow(dayDate: DayDate(date: date))
    }

    /**
     Shows the day view cell corresponding to today.
     */
    public func showToday() {
        dayScrollView.goToAndShow(dayDate: DayDate(date: Date()), showNow: true)
    }

    /**
     Overwrittes all events with new data.
     */
    public func loadEvents(withData eventsData: [EventData]?) {
        guard eventsData != nil else {
            return
        }
        dayScrollView.overwriteAllEvents(withData: eventsData)
    }

    // MARK: - INTERNAL FUNCTIONS -

    func zoomView(_ sender: UIPinchGestureRecognizer) {

        let currentScale = sender.scale
        var touchCenter: CGPoint! = nil

        if sender.numberOfTouches >= 2 {
            let touch1 = sender.location(ofTouch: 0, in: self)
            let touch2 = sender.location(ofTouch: 1, in: self)
            touchCenter = CGPoint(x: (touch1.x+touch2.x)/2, y: (touch1.y+touch2.y)/2)
        }

        dayScrollView.zoomContent(withNewScale: currentScale, newTouchCenter: touchCenter, andState: sender.state)
        updateTopAndSideBarConstraints()
    }

    func addLabel(forIndexPath indexPath: IndexPath, withDate date: DayDate) {

        var label: UILabel!
        if !discardedDayLabels.isEmpty {
            label = discardedDayLabels.remove(at: 0)
            label.frame = Util.generateDayLabelFrame(forIndex: indexPath)
        }
        else {
            label = Util.makeDayLabel(withIndexPath: indexPath)
        }

        if let newFontSize = Util.assignTextAndResizeFont(forLabel: label, andDate: date) {
            FontVariables.dayLabelCurrentFontSize = newFontSize
            updateVisibleLabels()
        }
        visibleDayLabels[date] = label
        self.topBarView.addSubview(label)
    }

    func discardLabel(withDate date: DayDate) {

        if let label = visibleDayLabels[date] {
            label.removeFromSuperview()
            visibleDayLabels.removeValue(forKey: date)
            discardedDayLabels.append(label)
        }
        trashExcessDayLabels()
    }

    func addAllDayEvents(_ events: [EventData], forIndexPath indexPath: IndexPath, withDate dayDate: DayDate) {
        let extraHeight = LayoutVariables.allDayEventVerticalSpacing*2+LayoutVariables.allDayEventHeight

        if self.topBarHeight < extraHeight {
            self.extraTopBarHeight = extraHeight
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }

        if visibleAllDayEvents[dayDate] != nil {
            for (_, layer) in visibleAllDayEvents[dayDate]! {
                layer.removeFromSuperlayer()
            }
            visibleAllDayEvents[dayDate] = nil
        }

        let max = events.count
        var i = 0
        var layers: [EventData: CAShapeLayer] = [:]
        for event in events {
            let frame = Util.generateAllDayEventFrame(forIndex: indexPath, at: i, max: max)
            let layer = Util.makeEventLayer(withData: event, andFrame: frame)
            self.topBarView.layer.addSublayer(layer)
            layers[event] = layer

            i += 1
        }
        self.visibleAllDayEvents[dayDate] = layers
    }

    func discardAllDayEvents(forDate dayDate: DayDate) {
        if visibleAllDayEvents[dayDate] != nil {
            for (_, layer) in visibleAllDayEvents[dayDate]! {
                layer.removeFromSuperlayer()
            }
            visibleAllDayEvents[dayDate] = nil
        }

        if visibleAllDayEvents.isEmpty && self.topBarHeight > LayoutVariables.defaultTopBarHeight {
            self.extraTopBarHeight = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }
    }

    func hasAllDayEvents(forDate dayDate: DayDate) -> Bool {
        return (visibleAllDayEvents[dayDate] != nil)
    }

    func tapTopBar(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(ofTouch: 0, in: self.topBarView)
        for (_, eventLayers) in visibleAllDayEvents {
            for (event, layer) in eventLayers {
                if layer.path!.contains(touchPoint) {
                    eventViewWasTapped(event)
                }
            }
        }
    }

    func updateVisibleLabelsAndMainConstraints() {
        resetFontValues()
        updateTopAndSideBarConstraints()
        updateVisibleLabels()
    }

    func updateTopAndSideBarPositions() {
        sideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.dayCollectionView.contentOffset.x + topBarLeftBuffer
    }

    func eventViewWasTapped(_ eventData: EventData) {
        self.delegate?.didTapEvent(in: self, eventId: eventData.id)
    }

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell, at hours: Int, and minutes: Int) {
        let date = dayViewCell.date.getDateWithTime(hours: hours, minutes: minutes, seconds: 0)
        self.delegate?.didLongPressDayView(in: self, atDate: date)
    }

    func requestEvents(between startDate: DayDate, and endDate: DayDate) {
        self.delegate?.loadNewEvents(in: self, between: startDate.dateObj, and: endDate.dateObj)
    }

    // MARK: - PRIVATE/HELPER FUNCTIONS -

    private func updateTopAndSideBarConstraints() {

        // Height of total side bar
        let dayViewCellHeight = LayoutVariables.dayViewCellHeight
        let dayViewCellHourHeight = dayViewCellHeight/DateSupport.hoursInDay
        let sideBarHeight = dayViewCellHeight + dayViewCellHourHeight

        // Set position and size constraints for side bar and hour view
        hourSideBarBottomConstraint.constant = dayViewCellHourHeight
        sideBarHeightConstraint.constant = sideBarHeight
        sideBarTopBuffer = LayoutVariables.dayViewVerticalSpacing - dayViewCellHourHeight/2

        // Set correct size and constraints of top bar view
        topBarWidthConstraint.constant = dayScrollView.dayCollectionView.contentSize.width
        topBarLeftBuffer = sideBarView.frame.width

        updateTopAndSideBarPositions()
    }

    private func updateVisibleLabels() {
        for cell in dayScrollView.dayCollectionView.visibleCells {
            let indexPath = dayScrollView.dayCollectionView.indexPath(for: cell)!
            if let dayViewCell = cell as? DayViewCell {
                let dayDate = dayViewCell.date

                if let label = visibleDayLabels[dayDate] {
                    label.frame = Util.generateDayLabelFrame(forIndex: indexPath)
                    label.font = FontVariables.dayLabelCurrentFont
                    label.textColor = FontVariables.dayLabelTextColor
                    if let newFontSize = Util.assignTextAndResizeFont(forLabel: label, andDate: dayDate) {
                        FontVariables.dayLabelCurrentFontSize = newFontSize
                        updateVisibleLabels()
                    }
                }
            }
        }
        trashExcessDayLabels()
        updateDiscardedLabels()
    }

    private func updateDiscardedLabels() {
        for label in discardedDayLabels {
            label.font = FontVariables.dayLabelCurrentFont
            label.textColor = FontVariables.dayLabelTextColor
        }
    }

    private func trashExcessDayLabels() {
        let maxAllowed = Int(LayoutVariables.visibleDays)

        if discardedDayLabels.count > maxAllowed {
            let overflow = discardedDayLabels.count - maxAllowed
            for i in 0...overflow {
                discardedDayLabels.remove(at: i)
            }
        }
    }

    private func resetFontValues() {
        FontVariables.dayLabelCurrentFontSize = FontVariables.dayLabelDefaultFont.pointSize
        Util.resetDayLabelTextMode()
    }

}

// MARK: - LAYOUT PROPERTIES EXTENSION -

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
            self.topBarHeight = self.extraTopBarHeight + height
            LayoutVariables.defaultTopBarHeight = height
            updateVisibleLabelsAndMainConstraints()
        }
    }

    /**
     Extra height added on to default top bar height.
     */
    internal var extraTopBarHeight: CGFloat {
        get {
            return self.topBarHeight-self.defaultTopBarHeight
        }
        set (extraHeight) {
            self.topBarHeight = LayoutVariables.defaultTopBarHeight + extraHeight
        }
    }

    /**
     Height of top bar.
     */
    private(set) var topBarHeight: CGFloat {
        get {
            return self.topBarView.frame.height
        }
        set(height) {
            self.topBarHeightConstraint.constant = height
            self.topLeftBufferHeightConstraint.constant = height
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
     The config that the day labels will show.
     */
    public var dayLabelShowYear: Bool {
        get {
            return FontVariables.dayLabelShowYear
        }
        set(bool) {
            FontVariables.dayLabelShowYear = bool
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

// MARK: - WEEKVIEW DELEGATE -

@objc public protocol WeekViewDelegate: class {
    func didLongPressDayView(in weekView: WeekView, atDate date: Date)

    func didTapEvent(in weekView: WeekView, eventId: String)

    func loadNewEvents(in weekView: WeekView, between startDate: Date, and endDate: Date)

}

// MARK: - WEEKVIEW LAYOUT VARIABLES -

public struct FontVariables {

    // Default font for all day labels
    fileprivate(set) static var dayLabelDefaultFont = LayoutDefaults.dayLabelFont {
        didSet {
            updateDayLabelCurrentFont()
        }
    }
    // Current font for all day labels
    private(set) static var dayLabelCurrentFont = LayoutDefaults.dayLabelFont
    // Text color for all day labels
    fileprivate(set) static var dayLabelTextColor = LayoutDefaults.dayLabelTextColor
    // Minimum font for all day labels
    fileprivate(set) static var dayLabelMinimumFontSize = LayoutDefaults.dayLabelMinimumFontSize
    // Minimum font for all day labels
    fileprivate(set) static var dayLabelCurrentFontSize = LayoutDefaults.dayLabelFont.pointSize {
        didSet {
            updateDayLabelCurrentFont()
        }
    }
    // Mode of the day labels
    fileprivate(set) static var dayLabelShowYear = true

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

    private static func updateHourMinScale () {
        hourLabelMinimumScale = hourLabelMinimumFontSize / hourLabelFont.pointSize
    }

    private static func updateDayLabelCurrentFont () {
        dayLabelCurrentFont = dayLabelDefaultFont.withSize(dayLabelCurrentFontSize)
    }

}

extension LayoutVariables {

    // Default height of the top bar
    fileprivate(set) static var defaultTopBarHeight = LayoutDefaults.defaultTopBarHeight

}
