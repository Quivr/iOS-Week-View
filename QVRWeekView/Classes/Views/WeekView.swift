//
//  CalendarView.swift

import Foundation
import UIKit

public typealias EventStlyeCallback = (CALayer, EventData?) -> Void

/**
 Class of the main week view. This view can be placed anywhere and will adapt to given size. All behaviours are internal,
 and all customization can be done with public functions. The is a WeekViewDelegate which can be used to receive certain events.
 WeekView can be used in both landscape and portrait mode.
 */
open class WeekView: UIView {
    // MARK: - OUTLETS -

    // Top bar view containing day labels
    @IBOutlet var topBarView: UIView!
    // Small buffer view in top left corner
    @IBOutlet var topLeftBufferView: UIView!
    // The view containing the hourSideBarView
    @IBOutlet var sideBarView: UIView!
    // Direct refence to hourSideBarView containing hour labels
    @IBOutlet var hourSideBarView: HourSideBarView!
    // The main scroll view in the center displaying day cells
    @IBOutlet var dayScrollView: DayScrollView!

    // MARK: - CONSTRAINTS -

    @IBOutlet var sideBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var sideBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hourSideBarYPositionConstraint: NSLayoutConstraint!
    @IBOutlet var hourSideBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var topBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var topBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var topBarXPositionConstraint: NSLayoutConstraint!
    @IBOutlet var topLeftBufferWidthConstraint: NSLayoutConstraint!
    @IBOutlet var topLeftBufferHeightConstraint: NSLayoutConstraint!

    // MARK: - PUBLIC PROPERTIES -

    // WeekView Delegate
    @objc public weak var delegate: WeekViewDelegate?

    // Determines what offset preservation technique is used when customising the current zoom scale.
    public var zoomOffsetPreservation: ZoomOffsetPreservation = .top

    // A DayDate range containing the current days visible on screen
    public var visibleDayDateRange: ClosedRange<DayDate> {
        let firstActiveDay = self.dayScrollView.activeDay
        return firstActiveDay...(firstActiveDay + Int(self.dayScrollView.visibleDays - 1))
    }

    //A date range containing the current days visible on screen
    public var visibleDateRange: ClosedRange<Date> {
        let firstActiveDay = self.dayScrollView.activeDay
        let lastActiveDay = (firstActiveDay + Int(self.dayScrollView.visibleDays - 1))
        return firstActiveDay.dateObj.getStartOfDay()...lastActiveDay.dateObj.getEndOfDay()
    }

    //Reloads the events from the delegate
    public func notifyDataSetChanged() {
        delegate?.eventLoadRequest(in: self, between: visibleDateRange.lowerBound, and: visibleDateRange.upperBound)
    }

    // All EventData of events currently visible on screen
    public var allVisibleEvents: [EventData] {
        var visibleEvents: [EventData] = []
        for day in visibleDayDateRange {
            visibleEvents.append(contentsOf: self.dayScrollView.getEventData(forDate: day))
        }
        return visibleEvents
    }

    // MARK: - CUSTOMIZATION -

    // Background color of main scrollview.
    @objc public var mainBackgroundColor: UIColor {
        get { self.mainView.backgroundColor! }
        set(color) { self.mainView.backgroundColor = color; self.sideBarView.backgroundColor = color }
    }
    // Background color of top bar containing day labels.
    @objc public var topBarColor: UIColor {
        get { self.topBarView.backgroundColor! }
        set(color) { self.topLeftBufferView.backgroundColor = color; self.topBarView.backgroundColor = color }
    }
    // Color of the side bar containing hour labels.
    @objc public var sideBarColor: UIColor {
        get { self.sideBarView.backgroundColor! }
        set(color) { self.sideBarView.backgroundColor = color }
    }
    // Width of the side bar containing hour labels.
    @objc public var sideBarWidth: CGFloat {
        get { self.sideBarView.frame.width }
        set(width) { self.sideBarWidthConstraint.constant = width; self.topLeftBufferWidthConstraint.constant = width }
    }
    // Default height of the top bar
    @objc public var defaultTopBarHeight: CGFloat = LayoutDefaults.defaultTopBarHeight {
        didSet { self.updateVisibleLabelsAndMainConstraints() }
    }
    // Font for all day labels contained in the top bar.
    @objc public var dayLabelDefaultFont: UIFont = LayoutDefaults.dayLabelFont {
        didSet { self.updateVisibleLabelsAndMainConstraints() }
    }
    // Text color for all day labels contained in the top bar.
    @objc public var dayLabelTextColor: UIColor = LayoutDefaults.dayLabelTextColor {
        didSet { self.updateVisibleLabelsAndMainConstraints() }
    }
    // Text color for today day label contained in the top bar.
    @objc public var dayLabelTodayTextColor: UIColor = LayoutDefaults.dayLabelTodayTextColor {
        didSet { updateVisibleLabelsAndMainConstraints() }
    }
    // Minimum font size that day label text will be resized to if label is too small.
    @objc public var dayLabelMinimumFontSize: CGFloat = LayoutDefaults.dayLabelMinimumFontSize {
        didSet { updateVisibleLabelsAndMainConstraints() }
    }
    // Short date format for day labels. See reference of date formats at: http://nsdateformatter.com/
    @objc public var dayLabelShortDateFormat: String {
        get { self.dayLabelDateFormats[.small]! }
        set(format) {
            self.dayLabelDateFormats[.small] = format
            updateVisibleLabelsAndMainConstraints()
        }
    }
    // Normal date format for day labels. See reference of date formats at: http://nsdateformatter.com/
    @objc public var dayLabelNormalDateFormat: String {
        get { self.dayLabelDateFormats[.normal]! }
        set(format) {
            self.dayLabelDateFormats[.normal] = format
            updateVisibleLabelsAndMainConstraints()
        }
    }
    // Long date format for day labels. See reference of date formats at: http://nsdateformatter.com/
    @objc public var dayLabelLongDateFormat: String {
        get { self.dayLabelDateFormats[.large]! }
        set(format) {
            self.dayLabelDateFormats[.large] = format
            updateVisibleLabelsAndMainConstraints()
        }
    }
    // Locale for the day labels. If none is given device locale will be used.
    @objc public var dayLabelDateLocale: Locale = NSLocale.current {
        didSet { updateVisibleLabelsAndMainConstraints() }
    }
    // Font for all hour labels contained in the side bar.
    @objc public var hourLabelFont: UIFont {
        get { self.hourSideBarView.hourLabelFont }
        set(font) { self.hourSideBarView.hourLabelFont = font }
    }
    // Text color for all hour labels contained in the side bar.
    @objc public var hourLabelTextColor: UIColor {
        get { self.hourSideBarView.hourLabelTextColor }
        set(color) { self.hourSideBarView.hourLabelTextColor = color }
    }
    // Minimum percentage that hour label text will be resized to if label is too small.
    @objc public var hourLabelMinimumFontSize: CGFloat {
        get { self.hourSideBarView.hourLabelMinimumFontSize }
        set(size) { self.hourSideBarView.hourLabelMinimumFontSize = size }
    }
    // Format of all hour labels.
    @objc public var hourLabelDateFormat: String {
        get { self.hourSideBarView.hourLabelDateFormat }
        set(format) { self.hourSideBarView.hourLabelDateFormat = format }
    }
    // Height of all day labels.
    @objc public var allDayEventHeight: CGFloat = LayoutDefaults.allDayEventHeight {
        didSet { self.updateAllDayEventLayers() }
    }
    // Height of all day labels.
    @objc public var allDayEventVerticalSpacing: CGFloat = LayoutDefaults.allDayVerticalSpacing {
       didSet { self.updateAllDayEventLayers() }
   }
    // Spread all day events on x axis, if not true than spread will be made on y axis.
    @objc public var allDayEventsSpreadOnX: Bool = LayoutDefaults.allDayEventsSpreadOnX {
        didSet { self.updateAllDayEventLayers() }
    }
    // Enable this to allow long events (that go from midnight to midnight) to be automatically converted to allDay events. (default true)
    @objc public var autoConvertAllDayEvents: Bool {
        get { self.dayScrollView.autoConvertLongEventsToAllDay }
        set(bool) { self.dayScrollView.autoConvertLongEventsToAllDay = bool }
    }

    // MARK: - PRIVATE VARIABLES -

    // The actual view being displayed, all other views are subview of this mainview
    private(set) var mainView: UIView!
    // Array of visible daylabels
    private var visibleDayLabels: [DayDate: UILabel] = [:]
    // Array of visible allDayEvents
    private var visibleAllDayEvents: [DayDate: [EventData: EventLayer]] = [:]
    // Array of labels not being displayed
    private var discardedDayLabels: [UILabel] = []
    // Left side buffer for top bar
    private var topBarLeftBuffer: CGFloat = 0
    // Top side buffer for side bar
    private var sideBarTopBuffer: CGFloat = 0
    // The scale of the latest pinch event
    private var lastTouchScale = CGFloat(0)
    // Current text mode of the day labels
    private var dayLabelTextMode: TextMode = .large
    // The formats used to show day label dates
    private var dayLabelDateFormats: [TextMode: String] = LayoutDefaults.dayLabelDateFormats
    // Minimum font for all day labels
    private var dayLabelCurrentFontSize = LayoutDefaults.dayLabelFont.pointSize
    // Current font for all day labels
    private var dayLabelCurrentFont: UIFont { dayLabelDefaultFont.withSize(self.dayLabelCurrentFontSize) }

    // Height of top bar.
    private var topBarHeight: CGFloat {
        get { return self.topBarView.frame.height }
        set(height) {
            self.topBarHeightConstraint.constant = height
            self.topLeftBufferHeightConstraint.constant = height
        }
    }
    // Extra height added on to default top bar height.
    private var extraTopBarHeight: CGFloat = 0 {
        didSet { self.topBarHeight = self.extraTopBarHeight + self.defaultTopBarHeight }
    }

    // MARK: - INITIALIZERS/OVERRIDES -

    /**
     Required init.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWeekView()
    }

    /**
     Override frame init.
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initWeekView()
    }

    /**
     Updates displayed time and requests event when moving to window.
     */
    open override func didMoveToWindow() {
        // Update the displayed time
        self.updateTimeDisplayed()
        // Redraw events (primarily to remove a possible preview)
        self.redrawEvents()
        // Request new events
        dayScrollView.requestEvents()
    }

    /**
      Custom initializer method.
     */
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

    /**
     Fetches the weekView nib and sets it as main view.
     */
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
     @objc public func updateTimeDisplayed() {
        if let dayCollectionView = dayScrollView.dayCollectionView {
            for cell in dayCollectionView.visibleCells {
                if let dayViewCell = cell as? DayViewCell {
                    dayViewCell.updateTimeView()
                }
            }
        }
    }

    /**
     Redraws all events in the dayview cells
     */
     @objc public func redrawEvents() {
        if let dayCollectionView = dayScrollView.dayCollectionView {
            for cell in dayCollectionView.visibleCells {
                if let dayViewCell = cell as? DayViewCell {
                    dayViewCell.setNeedsLayout()
                }
            }
        }
    }

    /**
     Shows the day view cell corresponding to asked day.
     */
     @objc public func showDay(withDate date: Date, showTime: Bool = false) {
        if showTime {
            dayScrollView.goToAndShow(dayDate: DayDate(date: date), showTime: date)
        } else {
            dayScrollView.goToAndShow(dayDate: DayDate(date: date))
        }
    }

    /**
     Shows the day view cell corresponding to today.
     */
     @objc public func showToday() {
        let now = Date()
        dayScrollView.goToAndShow(dayDate: DayDate(date: now), showTime: now)
    }

    /**
     Overwrittes all events with new data.
     */
    open func loadEvents(withData eventsData: [EventData]?) {
        guard eventsData != nil else {
            return
        }
        // Reload dayCollectionView data to prevent allDayEvent bugs.
        dayScrollView.dayCollectionView.reloadData()
        dayScrollView.overwriteAllEvents(withData: eventsData)
    }

    // MARK: - DELEGATE FUNCTIONS -

    /**
     Method delegates event view taps, and sends a callback with the event id up to the WeekViewDelegate.
     */
    func eventViewWasTapped(_ eventData: EventData) {
        self.delegate?.didTapEvent(in: self, withId: eventData.id)
    }

    /**
     Method delegates day view cell long presses, and sends a callback the pressed time up to the WeekViewDelegate.
     */
    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell, at hours: Int, and minutes: Int) {
        let date = dayViewCell.date.getDateWithTime(hours: hours, minutes: minutes, seconds: 0)
        self.delegate?.didLongPressDayView(in: self, atDate: date)
    }

    /**
     Method delegates active day change and sends a callback with the new day up to the WeekViewDelegate.
     */
    func activeDayWasChanged(to day: DayDate) {
        self.delegate?.activeDayChanged?(in: self, to: day.dateObj)
    }

    /**
     Method delegates event requests and sends a callback with start and end Date up to the WeekViewDelegate.
     */
    func requestEvents(between startDate: DayDate, and endDate: DayDate) {
        self.delegate?.eventLoadRequest(in: self, between: startDate.dateObj, and: endDate.dateObj)
    }

    // MARK: - INTERNAL FUNCTIONS -

    @objc func didEndVerticalScrolling(_ sender: DayScrollView) {
        self.delegate?.didEndVerticalScrolling?(in: self, top: sender.topOffset, bottom: sender.bottomOffset)
    }

    /**
     Triggered by pinch gesture to zoom the dayScrollView,
     */
    @objc func zoomView(_ sender: UIPinchGestureRecognizer) {

        let currentScale = sender.scale
        let state = sender.state
        var touchCenter: CGPoint! = nil

        if sender.numberOfTouches >= 2 {
            let touch1 = sender.location(ofTouch: 0, in: self)
            let touch2 = sender.location(ofTouch: 1, in: self)
            touchCenter = CGPoint(x: (touch1.x+touch2.x)/2, y: (touch1.y+touch2.y)/2)
        }

        dayScrollView.zoomContent(withNewScale: currentScale, newTouchCenter: touchCenter, andState: state)
        updateTopAndSideBarConstraints()

        if state == .cancelled || state == .ended || state == .failed {
            self.delegate?.didEndZooming?(in: self, scale: self.dayScrollView.zoomScaleCurrent)
        }
    }

    /**
     Adds a dayLabel at indexPath with given date.
     */
    func addDayLabel(forIndexPath indexPath: IndexPath, withDate dayDate: DayDate) {

        var label: UILabel!
        if !discardedDayLabels.isEmpty {
            label = discardedDayLabels.remove(at: 0)
            label.frame = self.generateDayLabelFrame(forIndex: indexPath)
        }
        else {
            label = self.makeDayLabel(withIndexPath: indexPath)
        }
        updateDayLabel(label, withDate: dayDate)
        visibleDayLabels[dayDate] = label
        self.topBarView.addSubview(label)
    }

    /**
     Discards the day label at given date. This does not completely remove the day label. It is stored as a
     discarded day label and can be recycled later.
     */
    func discardDayLabel(withDate date: DayDate) {

        if let label = visibleDayLabels[date] {
            label.removeFromSuperview()
            visibleDayLabels.removeValue(forKey: date)
            discardedDayLabels.append(label)
        }
        trashExtraDiscardedDayLabels()
    }

    /**
     Adds the allDayEvents provided by the events parameter at indexPath with given dayDate. This also triggers a topBar resize animation.
     */
    func addAllDayEvents(_ events: [EventData], forIndexPath indexPath: IndexPath, withDate dayDate: DayDate) {
        self.renderLayers(ofAllDayEvents: events, forIndexPath: indexPath, withDate: dayDate)
    }

    /**
     Removed the allDayEvents from given dayDate. Also triggers topBar resize animation.
     */
    func removeAllDayEvents(forDate dayDate: DayDate) {
        if visibleAllDayEvents[dayDate] != nil {
            for (_, layer) in visibleAllDayEvents[dayDate]! {
                layer.removeFromSuperlayer()
            }
            visibleAllDayEvents[dayDate] = nil
        }

        if visibleAllDayEvents.isEmpty && self.topBarHeight > self.defaultTopBarHeight {
            self.extraTopBarHeight = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }
    }

    /**
     Function returns true if there are allDayEvents at given dayDate.
     */
    func hasAllDayEvents(forDate dayDate: DayDate) -> Bool {
        return (visibleAllDayEvents[dayDate] != nil)
    }

    /**
     Method is triggered when the top bar is tapped.
     */
    @objc func tapTopBar(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(ofTouch: 0, in: self.topBarView)
        for (_, eventLayers) in visibleAllDayEvents {
            for (event, layer) in eventLayers {
                if layer.frame.contains(touchPoint) {
                    eventViewWasTapped(event)
                }
            }
        }
    }

    /**
     Method will reset font values, update the top and side baer constraints, and update all visible day labels.
     */
    func updateVisibleLabelsAndMainConstraints() {
        resetFontValues()
        updateTopAndSideBarConstraints()
        updateVisibleDayLabels()
        updateAllDayEventLayers()
    }

    /**
     Method will update top and side bar positions, so that they scroll along with the current dayScrollView.
     */
    func updateTopAndSideBarPositions() {
        hourSideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.dayCollectionView.contentOffset.x + topBarLeftBuffer
    }

    // MARK: - PRIVATE/HELPER FUNCTIONS -

    /**
     Method updates hour side bar height and position constraints, topBar height and width, and top left buffer size.
     */
    private func updateTopAndSideBarConstraints() {
        // Recalculate size of top bar height
        self.topBarHeight = self.extraTopBarHeight + self.defaultTopBarHeight

        // Height of total side bar
        let dayViewCellHourHeight = self.dayScrollView.dayViewCellHeight / DateSupport.hoursInDay
        let sideBarHeight = self.dayScrollView.dayViewCellHeight + dayViewCellHourHeight

        // Set position and size constraints for side bar and hour view
        self.hourSideBarHeightConstraint.constant = self.dayScrollView.dayViewCellHeight
        self.sideBarHeightConstraint.constant = sideBarHeight
        self.sideBarTopBuffer = self.dayScrollView.dayViewVerticalSpacing - (dayViewCellHourHeight / 2)

        // Set correct size and constraints of top bar view
        self.topBarWidthConstraint.constant = dayScrollView.dayCollectionView.contentSize.width
        self.topBarLeftBuffer = sideBarView.frame.width
        updateTopAndSideBarPositions()
    }

    /**
     Method updates frames, text and fonts of all visible day labels.
     */
    private func updateVisibleDayLabels() {
        for cell in dayScrollView.dayCollectionView.visibleCells {
            let indexPath = dayScrollView.dayCollectionView.indexPath(for: cell)!
            if let dayViewCell = cell as? DayViewCell {
                let dayDate = dayViewCell.date

                if let label = visibleDayLabels[dayDate] {
                    label.frame = self.generateDayLabelFrame(forIndex: indexPath)
                    updateDayLabel(label, withDate: dayDate)
                }
            }
        }
    }

    /**
     * Method regenerates the layers of all visible all day events
     */
    private func updateAllDayEventLayers() {
        for (dayDate, events) in self.visibleAllDayEvents {
            let visibleIndexPath = self.dayScrollView.visibleIndexPath(forDate: dayDate)
            guard let indexPath = visibleIndexPath else {
                continue
            }
            renderLayers(ofAllDayEvents: Array(events.keys), forIndexPath: indexPath, withDate: dayDate)
        }
    }

    /**
     * Method renders the layers for all day events
     */
    private func renderLayers(ofAllDayEvents events: [EventData], forIndexPath indexPath: IndexPath, withDate dayDate: DayDate) {
        let extraHeight = self.allDayEventVerticalSpacing * 2 + self.allDayEventHeight

        if self.extraTopBarHeight != extraHeight {
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

        var newEventLayers: [EventData: EventLayer] = [:]
        var i = 0
        for eventData in Util.sortedById(eventsToSort: events) {
            guard eventData.allDay else {
                continue
            }
            if let previousLayer = self.visibleAllDayEvents[dayDate]?[eventData] {
                previousLayer.removeFromSuperlayer()
            }
            let eventFrame = self.generateAllDayEventFrame(forIndex: indexPath, at: i, max: events.count)
            let layer = EventLayer(withFrame: eventFrame, layout: self.dayScrollView.dayViewCellLayout, andEvent: eventData)
            self.eventStyleCallback?(layer, eventData)
            newEventLayers[eventData] = layer
            self.topBarView.layer.addSublayer(layer)
            i += 1
        }
        self.visibleAllDayEvents[dayDate] = newEventLayers
    }

    /**
     Method updates a day labels font, text color and also performs a text assignment resize check.
     */
    private func updateDayLabel(_ dayLabel: UILabel, withDate dayDate: DayDate) {
        dayLabel.font = self.dayLabelCurrentFont
        dayLabel.textColor = dayDate == DayDate.today ? self.dayLabelTodayTextColor : self.dayLabelTextColor
        if let newFontSize = self.assignTextAndResizeFont(forLabel: dayLabel, andDate: dayDate) {
            self.dayLabelCurrentFontSize = newFontSize
            updateVisibleDayLabels()
        }
    }

    /**
     Method trashes any extra day labels in the discarded day label array.
     */
    private func trashExtraDiscardedDayLabels() {
        let maxAllowed = Int(self.dayScrollView.visibleDays)

        if discardedDayLabels.count > maxAllowed {
            let overflow = discardedDayLabels.count - maxAllowed
            for _ in 0...overflow {
                discardedDayLabels.removeFirst()
            }
        }
    }

    /**
     Method resets all font values such as font resizing and day label text mode.
     */
    private func resetFontValues() {
        self.dayLabelCurrentFontSize = self.dayLabelDefaultFont.pointSize
        self.dayLabelTextMode = .large
    }

    private func updateHourSideBarLabels() {
        for subView in self.sideBarView.subviews {
            if let hourSideBarView = subView as? HourSideBarView {
                hourSideBarView.updateLabels()
            }
        }
    }

    private func getString(forDate dayDate: DayDate, andMode mode: TextMode) -> String {
        let df = DateFormatter()
        df.dateFormat = self.dayLabelDateFormats[mode]
        df.locale = self.dayLabelDateLocale
        return df.string(from: dayDate.dateObj)
    }

    // Function returns a dayLabel UILabel with the correct size and position according to given indexPath.
    private func makeDayLabel(withIndexPath indexPath: IndexPath) -> UILabel {
        // Make as daylabel
        let labelFrame = self.generateDayLabelFrame(forIndex: indexPath)
        let dayLabel = UILabel(frame: labelFrame)
        dayLabel.textAlignment = .center
        return dayLabel
    }

    // Function generates a frame for a day label with given index path.
    private func generateDayLabelFrame(forIndex indexPath: IndexPath) -> CGRect {
        let row = CGFloat(indexPath.row)
        return CGRect(x: row*(self.dayScrollView.totalDayViewCellWidth), y: 0, width: self.dayScrollView.dayViewCellWidth, height: self.defaultTopBarHeight)
    }

    /**
     Functions generates a frame for an all day event according to the indexPath and
     the count (= how many'th all day event frame in current day) and the max (= how many all day events in current day.
     Depending on LayoutVariables.allDayEventsSpreadOnX, events will be spreaded on x or y axis.
     */
    private func generateAllDayEventFrame(forIndex indexPath: IndexPath, at count: Int, max: Int) -> CGRect {
        if self.allDayEventsSpreadOnX {
            let row = CGFloat(indexPath.row)
            let width = self.dayScrollView.dayViewCellWidth/CGFloat(max)
            return CGRect(x: row*(self.dayScrollView.totalDayViewCellWidth)+CGFloat(count)*width,
                          y: self.defaultTopBarHeight+self.allDayEventVerticalSpacing,
                          width: width,
                          height: self.allDayEventHeight)

        } else {
            let row = CGFloat(indexPath.row)
            let height = self.allDayEventHeight/CGFloat(max)
            return CGRect(x: row*(self.dayScrollView.totalDayViewCellWidth),
                          y: self.defaultTopBarHeight+CGFloat(count)*height,
                          width: self.dayScrollView.dayViewCellWidth,
                          height: height)
        }
    }

    /**
     Function will analyse the valid strings given from the dayDate object and determines which string will fit into the given
     label. Function will also check for font resizing if neccessary and will return the new font size if it is different to the
     current font size.
     */
    private func assignTextAndResizeFont(forLabel label: UILabel, andDate dayDate: DayDate) -> CGFloat? {
        let currentFont = label.font!
        let labelWidth = label.frame.width
        var possibleText = self.getString(forDate: dayDate, andMode: self.dayLabelTextMode) as NSString
        var textSize = possibleText.size(withAttributes: [.font: currentFont])

        label.text = possibleText as String
        if textSize.width > labelWidth && self.dayLabelTextMode != .small {
            possibleText = getString(forDate: dayDate, andMode: .normal) as NSString
            textSize = possibleText.size(withAttributes: [.font: currentFont])
            if textSize.width <= labelWidth {
                label.text = possibleText as String
                self.dayLabelTextMode = .normal
            }
            else {
                let scale = (labelWidth / textSize.width)
                var newFont = currentFont.withSize(floor(currentFont.pointSize*scale))

                while possibleText.size(withAttributes: [.font: newFont]).width > labelWidth && newFont.pointSize > self.dayLabelMinimumFontSize {
                    newFont = newFont.withSize(newFont.pointSize-0.25)
                }

                if newFont.pointSize < self.dayLabelMinimumFontSize {
                    newFont = newFont.withSize(self.dayLabelMinimumFontSize)
                }

                label.font = newFont
                if possibleText.size(withAttributes: [.font: newFont]).width > labelWidth {
                    label.text = getString(forDate: dayDate, andMode: .small)
                    self.dayLabelTextMode = .small
                }
                else {
                    label.text = possibleText as String
                    self.dayLabelTextMode = .normal
                }

                if newFont.pointSize < self.dayLabelCurrentFont.pointSize {
                    label.font = newFont
                    return newFont.pointSize
                }
            }
        }
        return nil
    }
}

// MARK: - WEEKVIEW DELEGATE -

/**
 Protocol methods.
 */
@objc public protocol WeekViewDelegate: class {
    func didLongPressDayView(in weekView: WeekView, atDate date: Date)

    func didTapEvent(in weekView: WeekView, withId eventId: String)

    func eventLoadRequest(in weekView: WeekView, between startDate: Date, and endDate: Date)

    @objc optional func activeDayChanged(in weekView: WeekView, to date: Date)

    @objc optional func didEndZooming(in weekView: WeekView, scale zoomScale: CGFloat)

    @objc optional func didEndVerticalScrolling(in weekView: WeekView, top topOffset: Double, bottom bottomOffset: Double)
}
