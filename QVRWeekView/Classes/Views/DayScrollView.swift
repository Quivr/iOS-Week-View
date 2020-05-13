// swiftlint:disable private_over_fileprivate

import Foundation
import UIKit

// MARK: - DAY SCROLL VIEW -

/**
 Class of the scroll view contained within the WeekView.
 */
class DayScrollView: UIScrollView, UIScrollViewDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, DayViewCellDelegate, FrameCalculatorDelegate {

    // MARK: - INTERNAL VARIABLES -

    // The WeekView that this DayScrollView belongs to
    var weekView: WeekView? { self.superview?.superview as? WeekView }
    // Percentual offset at the top of the current DayScrollView
    var topOffset: Double {
        get { Double(self.verticalOffset / self.contentSize.height) }
        set { self.verticalOffset = CGFloat(Double(self.contentSize.height) * newValue) }
    }
    // Percentual offset at the bottom of the current DayScrollView
    var bottomOffset: Double {
        get { Double((self.frame.size.height + self.verticalOffset) / self.contentSize.height) }
        set { self.verticalOffset = CGFloat(Double(self.contentSize.height) * newValue) - self.frame.height }
    }
    // Percentual offset in the center of the current DayScrollView
    var centerOffset: Double {
        get { self.topOffset + Double((self.frame.height / 2) / self.contentSize.height) }
        set { self.verticalOffset = CGFloat(Double(self.contentSize.height) * newValue) - self.frame.height / 2 }
    }

    // Number of visible days when in portait mode.
    var visibleDaysInPortraitMode: CGFloat = LayoutDefaults.visibleDaysPortrait { didSet { updateLayout() } }
    // Number of visible days when in landscape mode.
    var visibleDaysInLandscapeMode: CGFloat = LayoutDefaults.visibleDaysLandscape { didSet { updateLayout() } }
    // Width of spacing between day columns in portrait mode
    var portraitDayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing { didSet { updateLayout() } }
    // Width of spacing between day columns in landscape mode
    var landscapeDayViewHorizontalSpacing = LayoutDefaults.landscapeDayViewHorizontalSpacing { didSet { updateLayout() } }
    // Amount of spacing above and below day view cells when in portrait mode.
    var portraitDayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing { didSet { updateLayout() } }
    // Amount of spacing above and below day view cells when in landscape mode.
    var landscapeDayViewVerticalSpacing = LayoutDefaults.landscapeDayViewVerticalSpacing { didSet { updateLayout() } }
    // Number of currently visible day view cells
    var visibleDays: CGFloat { UIDevice.current.orientation.isPortrait ? self.visibleDaysInPortraitMode : self.visibleDaysInLandscapeMode }
    // Width of spacing between day columns in landscape mode
    var dayViewHorizontalSpacing: CGFloat { UIDevice.current.orientation.isPortrait ? self.portraitDayViewHorizontalSpacing : self.landscapeDayViewHorizontalSpacing }
    // Height of spacing between day columns and borders
    var dayViewVerticalSpacing: CGFloat { UIDevice.current.orientation.isPortrait ? self.portraitDayViewVerticalSpacing : self.landscapeDayViewVerticalSpacing }
    // Height of a single day view cell
    var initialDayViewCellHeight: CGFloat = LayoutDefaults.dayViewCellHeight { didSet { updateLayout() } }
    // Width of a single day view cell
    var dayViewCellWidth: CGFloat { (self.frame.width - dayViewHorizontalSpacing*(visibleDays-1)) / visibleDays }
    // Width of a single day view cell
    var dayViewCellHeight: CGFloat { self.zoomScaleCurrent * self.initialDayViewCellHeight }
    // Total width of a day view cell including spacing
    var totalDayViewCellWidth: CGFloat { self.dayViewCellWidth + dayViewHorizontalSpacing }
    // Width of all scrollable content
    var totalContentWidth: CGFloat { CGFloat(self.dayCollectionViewCellCount) * self.totalDayViewCellWidth + self.dayViewHorizontalSpacing }
    // Height of all scrollable content
    var totalContentHeight: CGFloat { dayViewVerticalSpacing * 2 + dayViewCellHeight }
    // Zoom scale of current layout
    var zoomScaleCurrent: CGFloat = CGFloat(1) { didSet { updateLayout() } }
    // Maximum possible zoom scale
    var zoomScaleMax: CGFloat = LayoutDefaults.maximumZoom { didSet { updateLayout() } }
    // Minimum possible zoom scale
    var zoomScaleMin: CGFloat = LayoutDefaults.minimumZoom { didSet { updateLayout() } }
    // Velocity multiplier for scrolling
    var velocityOffsetMultiplier: CGFloat = LayoutDefaults.velocityOffsetMultiplier { didSet { updateLayout() } }
    // Enable this to allow long events (that go from midnight to midnight) to be automatically converted to allDay events. (default true)
    var autoConvertLongEventsToAllDay: Bool = true

    // MARK: - PRIVATE VARIABLES -

    // Min x-axis value that repeating starts at
    private var minOffsetX = CGFloat(0)
    // Min y-axis value that can be scrolled to
    private var minOffsetY = CGFloat(0)
    // Max x-axis value that can be scrolled to
    private var maxOffsetX: CGFloat { CGFloat(DateSupport.getDaysInYear(activeYear)) * self.totalDayViewCellWidth }
    // Max y-axis values that can be scrolled to
    private var maxOffsetY: CGFloat { (self.totalContentHeight - self.frame.height) < self.minOffsetY ? self.minOffsetY : (self.totalContentHeight - self.frame.height) }
    // Collection view
    private(set) var dayCollectionView: DayCollectionView!
    // Number of cells in collection view
    private var dayCollectionViewCellCount: Int { DateSupport.getDaysInYear(activeYear) + Int(max(self.visibleDaysInLandscapeMode, self.visibleDaysInPortraitMode)) }
    // EventData objects that are not all-day events
    private(set) var eventsData: [DayDate: [String: EventData]] = [:]
    // Event frames for all non all-day events
    private(set) var eventFrames: [DayDate: [String: CGRect]] = [:]
    // All fullday events
    private var allDayEventsData: [DayDate: [EventData]] = [:]
    // All active dayViewCells
    private(set) var dayViewCells: [Int: DayViewCell] = [:]
    // All frame calculators
    private var frameCalculators: [DayDate: FrameCalculator] = [:]
    // Active year on view
    private var activeYear: Int = DayDate.today.year
    // Current active day
    private(set) var activeDay: DayDate = DayDate.today { didSet { self.weekView?.activeDayWasChanged(to: self.activeDay) } }
    // Year todauy
    private var yearToday: Int = DayDate.today.year
    // Current period
    private var currentPeriod: Period = Period(ofDate: DayDate.today)
    // Bool stores is view is scrolling to a specific day
    private var scrollingToDay: Bool = false
    // Previous zoom scale of content relative to start of current gesture
    private var previousZoomTouch: CGPoint?
    // Zoom scale of content relative to start of current gesture
    private var lastTouchZoomScale = CGFloat(1)
    // Offset added to the offset when displaying now
    private static let showNowOffset = 0.005
    // Day view cell layout object
    private let dayViewCellLayout: DayViewCellLayout = DayViewCellLayout()

    // The vertical scrolling offset of the current DayScrollView.
    private var verticalOffset: CGFloat {
        get {
            return self.contentOffset.y
        }
        set {
            let offset = newValue > self.maxOffsetY
                ? self.maxOffsetY
                : (newValue < self.minOffsetY ? self.minOffsetY : newValue)
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: offset), animated: false)
        }
    }

    // MARK: - CONSTRUCTORS/OVERRIDES -

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDayScrollView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initDayScrollView()
    }

    /**
     Generates and fills the scroll view with day columns.
     */
    private func initDayScrollView() {

        let flowLayout = DayCollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.dayViewCellWidth, height: self.dayViewCellHeight)
        flowLayout.minimumLineSpacing = self.dayViewHorizontalSpacing
        flowLayout.velocityMultiplier = self.velocityOffsetMultiplier

        // Make day collection view and add it to frame
        dayCollectionView = DayCollectionView(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: self.bounds.width,
                                                            height: self.totalContentHeight),
                                              collectionViewLayout: flowLayout)
        dayCollectionView.contentOffset = CGPoint(x: calcXOffset(forDay: DayDate.today.dayInYear), y: 0)
        dayCollectionView.contentSize = CGSize(width: self.totalContentWidth, height: self.totalContentHeight)
        dayCollectionView.delegate = self
        dayCollectionView.dataSource = self
        self.addSubview(dayCollectionView)

        // Set content size for vertical scrolling
        self.contentSize = CGSize(width: self.bounds.width, height: dayCollectionView.frame.height)
        self.showNow()

        // Add tap gesture recognizer
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))

        // Set scroll view properties
        self.isDirectionalLockEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        self.delegate = self
    }

    override func layoutSubviews() {
        updateLayout()
    }

    // MARK: - GESTURE, SCROLL & DATA SOURCE FUNCTIONS -

    @objc func tap(_ sender: UITapGestureRecognizer) {

        if !self.dayCollectionView.isDragging && !self.dayCollectionView.isDecelerating {
            scrollToNearestCell()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Handle side and top bar animations
        self.weekView?.updateTopAndSideBarPositions()

        if let collectionView = scrollView as? DayCollectionView {
            if collectionView.contentOffset.x < self.minOffsetX {
                resetView(withYearOffsetChange: -1)
            }
            else if collectionView.contentOffset.x > self.maxOffsetX {
                resetView(withYearOffsetChange: 1)
            }

            let cvLeft = CGPoint(x: collectionView.contentOffset.x, y: collectionView.center.y + collectionView.contentOffset.y)
            if  let path = collectionView.indexPathForItem(at: cvLeft),
                let dayViewCell = collectionView.cellForItem(at: path) as? DayViewCell,
                !scrollingToDay, activeDay != dayViewCell.date {

                self.activeDay = dayViewCell.date
                if activeDay > currentPeriod.lateMidLimit {
                    updatePeriod()
                }
                else if activeDay < currentPeriod.earlyMidLimit {
                    updatePeriod()
                }
            }
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView is DayCollectionView && scrollingToDay {
            scrollingToDay = false
            requestEvents()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.weekView?.didEndVerticalScrolling(self)
            scrollToNearestCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.weekView?.didEndVerticalScrolling(self)
        scrollToNearestCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dayCollectionViewCellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dayViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellKeys.dayViewCell, for: indexPath) as? DayViewCell {
            dayViewCell.clearValues()
            dayViewCell.delegate = self
            dayViewCell.layout = self.dayViewCellLayout // NOTE: Pass by reference
            dayViewCells[dayViewCell.id] = dayViewCell
            let dayDateForCell = getDayDate(forIndexPath: indexPath)
            dayViewCell.setDate(as: dayDateForCell)
            if let eventDataForCell = eventsData[dayDateForCell], let eventFramesForCell = eventFrames[dayDateForCell] {
                dayViewCell.setEventsData(eventDataForCell, andFrames: eventFramesForCell)
            }
            return dayViewCell
        }
        return UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dayViewCell = cell as? DayViewCell {
            let dayDate = dayViewCell.date
            self.weekView?.addDayLabel(forIndexPath: indexPath, withDate: dayDate)
            if let allDayEvents = allDayEventsData[dayDate] {
                self.weekView?.addAllDayEvents(allDayEvents, forIndexPath: indexPath, withDate: dayDate)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dayViewCell = cell as? DayViewCell {
            let dayDate = dayViewCell.date
            self.weekView?.discardDayLabel(withDate: dayDate)
            if self.weekView?.hasAllDayEvents(forDate: dayDate) == true {
                self.weekView?.removeAllDayEvents(forDate: dayDate)
            }
        }
    }

    func eventViewWasTappedIn(_ dayViewCell: DayViewCell, withEventData eventData: EventData) {
        self.weekView?.eventViewWasTapped(eventData)
    }

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell, hours: Int, minutes: Int) {
        self.weekView?.dayViewCellWasLongPressed(dayViewCell, at: hours, and: minutes)
        for (_, dayViewCell) in dayViewCells {
            dayViewCell.addingEvent = true
        }
    }

    // solution == nil => do not render events. solution.isEmpty => render empty
    func passSolution(fromCalculator calculator: FrameCalculator, solution: [String: CGRect]?) {
        let date = calculator.date
        eventFrames[date] = solution
        frameCalculators[date] = nil
        for (_, dayViewCell) in dayViewCells where dayViewCell.date == date {
            if let eventsData = eventsData[date], let eventFrames = eventFrames[date] {
                dayViewCell.setEventsData(eventsData, andFrames: eventFrames)
            }
            else if solution != nil {
                dayViewCell.setEventsData([:], andFrames: [:])
            }
        }
    }

    // MARK: - INTERNAL FUNCTIONS -

    func getEventData(forDate dayDate: DayDate) -> [EventData] {
        var allEvents: [EventData] = []
        if let regularEventData = self.eventsData[dayDate]?.values {
            allEvents.append(contentsOf: regularEventData)
        }
        if let allDayEvents = allDayEventsData[dayDate] {
            allEvents.append(contentsOf: allDayEvents)
        }
        return allEvents
    }

    func showNow() {
        self.topOffset = Double(DateSupport.getPercentTodayPassed()) - DayScrollView.showNowOffset
    }

    func goToAndShow(dayDate: DayDate, showTime: Date? = nil) {
        let animated = dayDate.year == activeYear
        activeYear = dayDate.year
        currentPeriod = Period(ofDate: dayDate)
        activeDay = dayDate
        if animated {
            scrollingToDay = true
        }
        dayCollectionView.setContentOffset(CGPoint(x: calcXOffset(forDay: dayDate.dayInYear),
                                                   y: 0),
                                           animated: animated)
        if !animated {
            requestEvents()
        }
        dayCollectionView.reloadData()

        if let time = showTime {
            let yOffset = self.totalContentHeight*time.getPercentDayPassed()-(self.frame.height/2)
            let minOffsetY = self.minOffsetY
            let maxOffsetY = self.maxOffsetY
            self.setContentOffset(CGPoint(x: 0, y: yOffset < minOffsetY ? minOffsetY : (yOffset > maxOffsetY ? maxOffsetY : yOffset)), animated: true)
        }
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter: CGPoint?, andState state: UIGestureRecognizer.State) {

        // Store previous zoom scale
        let previousZoom = self.zoomScaleCurrent

        var zoomChange = CGFloat(0)
        // If zoom just began, set last touch scale
        if state == .began {
            lastTouchZoomScale = newZoomScale
        }
        else {
            // Calculate zoom change from lastTouch and new zoom scale.
            zoomChange = newZoomScale - lastTouchZoomScale
            self.lastTouchZoomScale = newZoomScale
        }

        // Set current zoom
        var currentZoom = previousZoom + zoomChange
        if currentZoom < self.zoomScaleMin {
            currentZoom = self.zoomScaleMin
        }
        else if currentZoom > self.zoomScaleMax {
            currentZoom = self.zoomScaleMax
        }
        self.zoomScaleCurrent = currentZoom

        // Calculate the new y content offset based on zoom change and touch center
        let m = previousZoom/currentZoom

        var newYOffset = self.contentOffset.y
        if touchCenter != nil {
            let oldAnchorY = touchCenter!.y+self.contentOffset.y
            let offsetChange = oldAnchorY*(m-1)
            newYOffset -= offsetChange
        }

        // Calculate additional y content offset change based on scrolling movements
        if let previousTouchCenter = previousZoomTouch {
            if let touch = touchCenter {
                newYOffset += (previousTouchCenter.y-touch.y)
                self.previousZoomTouch = touchCenter
            }
        }
        else {
            self.previousZoomTouch = touchCenter
        }

        // Check that new y offset is not out of bounds
        if newYOffset < self.minOffsetY {
            newYOffset = self.minOffsetY
        }
        else if newYOffset > self.maxOffsetY {
            newYOffset = self.maxOffsetY
        }

        // Pass new y offset to scroll view
        self.contentOffset.y = newYOffset

        if state == .cancelled || state == .ended || state == .failed {
            self.previousZoomTouch = nil
            for (_, cell) in dayViewCells {
                cell.updateEventTextFontSize()
            }
            scrollToNearestCell()
        }
    }

    func getDayDate(forIndexPath indexPath: IndexPath) -> DayDate {
        let date = DateSupport.getDate(fromDayOfYear: indexPath.row, forYear: activeYear)
        return DayDate(date: date)
    }

    func overwriteAllEvents(withData eventsData: [EventData]!) {
        guard eventsData != nil else {
            return
        }

        // New eventsdata
        var newEventsData: [DayDate: [String: EventData]] = [:]
        // New all day events
        var newAllDayEvents: [DayDate: [EventData]] = [:]
        // Stores the days which will be changed
        var changedDayDates = Set<DayDate>()

        // Process raw event data and sort it into the allEventsData dictionary. Also check to see which
        // days have had any changes done to them to queue them up for processing.
        for eventData in eventsData {
            let possibleSplitEvents = eventData.checkForSplitting(andAutoConvert: self.autoConvertLongEventsToAllDay)
            for (dayDate, event) in possibleSplitEvents {
                if event.allDay {
                    newAllDayEvents.addEvent(event, onDay: dayDate)
                }
                else {
                    if !changedDayDates.contains(dayDate) && Util.isEvent(event, fromDay: dayDate, notInOrHasChanged: self.eventsData) {
                        changedDayDates.insert(dayDate)
                    }
                    newEventsData.addEvent(event, onDay: dayDate)
                }
            }
        }

        // Get sequence of active days
        let activeDates = DateSupport.getAllDayDates(between: self.currentPeriod.startDate,
                                                     and: self.currentPeriod.endDate)
        // Iterate through all old days that have not been checked yet to look for inactive days
        for (dayDate, oldEvents) in self.eventsData where !changedDayDates.contains(dayDate) && activeDates.contains(dayDate) {
            for (_, oldEvent) in oldEvents where Util.isEvent(oldEvent, fromDay: dayDate, notInOrHasChanged: newEventsData) {
                changedDayDates.insert(dayDate)
                break
            }
        }

        self.eventsData = newEventsData
        self.allDayEventsData = newAllDayEvents
        for cell in self.dayCollectionView.visibleCells {
            if let dayViewCell = cell as? DayViewCell {
                let dayDate = dayViewCell.date
                let allThisDayEvents = self.allDayEventsData[dayDate]
                if allThisDayEvents == nil && self.weekView?.hasAllDayEvents(forDate: dayDate) == true {
                    self.weekView?.removeAllDayEvents(forDate: dayDate)
                    dayViewCell.setNeedsLayout()
                } else if allThisDayEvents != nil {
                    self.weekView?.addAllDayEvents(allThisDayEvents!, forIndexPath: self.dayCollectionView.indexPath(for: cell)!, withDate: dayDate)
                    dayViewCell.setNeedsLayout()
                }
            }
        }

        // Process events for days with changed data, sort them to load visible days first
        let sortedChangedDays: [DayDate] = changedDayDates.sorted { (smaller, larger) -> Bool in
            let diff1 = abs(smaller.dayInYear - self.activeDay.dayInYear)
            let diff2 = abs(larger.dayInYear - self.activeDay.dayInYear)
            return diff1 == diff2 ? smaller > larger : diff1 < diff2
        }
        for dayDate in sortedChangedDays {
            self.processEventsData(forDayDate: dayDate)
        }
        // Redraw days with no changed data
        for (_, dayViewCell) in self.dayViewCells where !sortedChangedDays.contains(dayViewCell.date) {
            dayViewCell.setNeedsLayout()
        }
    }

    func requestEvents() {
        if !scrollingToDay {
            self.currentPeriod = Period(ofDate: activeDay)
            let startDate = currentPeriod.startDate
            let endDate = currentPeriod.endDate
            self.weekView?.requestEvents(between: startDate, and: endDate)
        }
    }

    func visibleIndexPath(forDate dayDate: DayDate) -> IndexPath? {
        return self.dayCollectionView.visibleCells.reduce(nil, {(result, cell) -> IndexPath? in
            if let dayViewCell = cell as? DayViewCell, dayViewCell.date == dayDate {
                return self.dayCollectionView.indexPath(for: cell)
            }
            return result
        })
    }

    // MARK: - HELPER/PRIVATE FUNCTIONS -

    // Forces synchronous execution of event overwrite with the given data
    private func forceSyncOverwriteAllEvents(overwriteData: [EventData]) {
        DispatchQueue.main.sync {
            overwriteAllEvents(withData: overwriteData)
        }
    }

    fileprivate func updateLayout() {

        // Get old offset ratio before resizing cells
        let oldXOffset = dayCollectionView.contentOffset.x
        let oldWidth = dayCollectionView.contentSize.width

        // Update scroll view content size
        self.contentSize = CGSize(width: self.frame.width, height: self.totalContentHeight)

        // Update size of day view cells
        updateDayViewCellSizeAndSpacing()
        // Update frame of day collection view
        dayCollectionView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.totalContentHeight)

        if oldWidth != self.totalContentWidth {
            dayCollectionView.contentOffset = CGPoint(x: calcXOffset(forDay: activeDay.dayInYear), y: 0)
        } else {
            dayCollectionView.contentOffset = CGPoint(x: oldXOffset, y: 0)
        }

        // Update content size
        dayCollectionView.contentSize = CGSize(width: self.totalContentWidth, height: self.totalContentHeight)

        self.weekView?.updateVisibleLabelsAndMainConstraints()
    }

    private func resetView(withYearOffsetChange change: Int) {
        activeYear += change

        if change < 0 {
            dayCollectionView.contentOffset.x = self.maxOffsetX
        } else if change > 0 {
            dayCollectionView.contentOffset.x = self.minOffsetX
        }
    }

    private func scrollToNearestCell() {

        let xOffset = dayCollectionView.contentOffset.x
        let yOffset = dayCollectionView.contentOffset.y

        let totalDayViewWidth = self.totalDayViewCellWidth
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)

        if truncatedToPagingWidth >= 0.5 && yOffset >= self.minOffsetY && yOffset <= self.maxOffsetY {
            dayCollectionView.setContentOffset(CGPoint(x: calcXOffset(forDay: round(xOffset / totalDayViewWidth)),
                                                       y: dayCollectionView.contentOffset.y), animated: true)
        }
    }

    private func updateDayViewCellSizeAndSpacing() {
        if let flowLayout = dayCollectionView.collectionViewLayout as? DayCollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.dayViewCellWidth, height: self.dayViewCellHeight)
            flowLayout.minimumLineSpacing = self.dayViewHorizontalSpacing
            flowLayout.velocityMultiplier = self.velocityOffsetMultiplier
        }
    }

    private func processEventsData(forDayDate dayDate: DayDate) {
        let calc = FrameCalculator(date: dayDate)
        calc.delegate = self
        frameCalculators[dayDate]?.cancelCalculation()
        frameCalculators[dayDate] = calc
        calc.calculate(withData: eventsData[dayDate])
    }

    private func updatePeriod() {
        // Set current period to new period
        self.currentPeriod = Period(ofDate: self.activeDay)
        // Load new events for new period
        requestEvents()
    }

    private func calcXOffset(forDay day: Int) -> CGFloat {
        return calcXOffset(forDay: CGFloat(day))
    }

    private func calcXOffset(forDay day: CGFloat) -> CGFloat {
        return day * self.totalDayViewCellWidth
    }
}

// MARK: - PERIOD CHANGE ENUM -

fileprivate enum PeriodChange {
    case forward
    case backward
}

// MARK: - CUSTOMIZATION EXTENSION -

extension DayScrollView {
    /**
     Default font for event labels.
     */
    var eventLabelFont: UIFont {
        get { self.dayViewCellLayout.eventLabelFont }
        set(font) {
            self.dayViewCellLayout.eventLabelFont = font
            updateLayout()
        }
    }
    /**
     Thin font for event labels.
     */
    var eventLabelInfoFont: UIFont {
        get { self.dayViewCellLayout.eventLabelInfoFont }
        set(font) {
            self.dayViewCellLayout.eventLabelInfoFont = font
            updateLayout()
        }
    }
    /**
     Text color for event labels.
     */
    var eventLabelTextColor: UIColor {
        get { self.dayViewCellLayout.eventLabelTextColor }
        set(color) {
            self.dayViewCellLayout.eventLabelTextColor = color
            updateLayout()
        }
    }
    /**
     Horizontal padding of the text within event labels.
     */
    var eventLabelHorizontalTextPadding: CGFloat {
        get { self.dayViewCellLayout.eventLabelHorizontalTextPadding }
        set(padding) {
            self.dayViewCellLayout.eventLabelHorizontalTextPadding = padding
            updateLayout()
        }
    }
    /**
     Vertical padding of the text within event labels.
     */
    var eventLabelVerticalTextPadding: CGFloat {
        get { self.dayViewCellLayout.eventLabelVerticalTextPadding }
        set(padding) {
            self.dayViewCellLayout.eventLabelVerticalTextPadding = padding
            updateLayout()
        }
    }
    /**
     Text of the preview event.
     */
    var previewEventText: String {
        get { self.dayViewCellLayout.previewEventText }
        set(text) {
            self.dayViewCellLayout.previewEventText = text
            updateLayout()
        }
    }
    /**
     Color of the preview event.
     */
    @objc var previewEventColor: UIColor {
        get { self.dayViewCellLayout.previewEventColor }
        set(color) {
            self.dayViewCellLayout.previewEventColor = color
            updateLayout()
        }
    }
    /**
     Text of the preview event.
     */
    var previewEventHeightInHours: Double {
        get {
            self.dayViewCellLayout.previewEventHourHeight
        }
        set(height) {
            self.dayViewCellLayout.previewEventHourHeight = height
            updateLayout()
        }
    }
    /**
     Precision of the preview event.
     */
    var previewEventPrecisionInMinutes: Double {
        get { self.dayViewCellLayout.previewEventMinutePrecision }
        set(minutes) {
            self.dayViewCellLayout.previewEventMinutePrecision = minutes
            updateLayout()
        }
    }
    /**
     Show preview on long press.
     */
    var showPreviewOnLongPress: Bool {
        get { self.dayViewCellLayout.showPreview }
        set(show) {
            self.dayViewCellLayout.showPreview = show
            updateLayout()
        }
    }
    /**
    Color of default day view color.
     */
    var defaultDayViewColor: UIColor {
        get { self.dayViewCellLayout.defaultDayViewColor }
        set(color) {
            self.dayViewCellLayout.defaultDayViewColor = color
            updateLayout()
        }
    }
    /**
     Color of weekend day view color.
     */
    var weekendDayViewColor: UIColor {
        get { self.dayViewCellLayout.weekendDayViewColor }
        set(color) {
            self.dayViewCellLayout.weekendDayViewColor = color
            updateLayout()
        }
    }
    /**
     Color of a passed day view color.
     */
    var passedDayViewColor: UIColor {
        get { self.dayViewCellLayout.passedDayViewColor }
        set(color) {
            self.dayViewCellLayout.passedDayViewColor = color
            updateLayout()
        }
    }
    /**
     Color of a passed weekend day view color.
     */
    var passedWeekendDayViewColor: UIColor {
        get { self.dayViewCellLayout.passedWeekendDayViewColor }
        set(color) {
            self.dayViewCellLayout.passedWeekendDayViewColor = color
            updateLayout()
        }
    }
    /**
     Color of today's day view.
     */
    var todayViewColor: UIColor {
        get { self.dayViewCellLayout.todayViewColor }
        set(color) {
            self.dayViewCellLayout.todayViewColor = color
            updateLayout()
        }
    }
    /**
     Color of day view hour indicators.
     */
    var hourIndicatorColor: UIColor {
        get { self.dayViewCellLayout.hourIndicatorColor }
        set(color) {
            self.dayViewCellLayout.hourIndicatorColor = color
            updateLayout()
        }
    }
    /**
     Thickness of day view hour indicators.
     */
    var hourIndicatorThickness: CGFloat {
        get { self.dayViewCellLayout.hourIndicatorThickness }
        set(thickness) {
            self.dayViewCellLayout.hourIndicatorThickness = thickness
            updateLayout()
        }
    }
    /**
     Color of the main day view separators.
     */
    var mainSeparatorColor: UIColor {
        get { self.dayViewCellLayout.mainSeparatorColor }
        set(color) {
            self.dayViewCellLayout.mainSeparatorColor = color
            updateLayout()
        }
    }
    /**
     Thickness of the main day view separators.
     */
    var mainSeparatorThickness: CGFloat {
        get { self.dayViewCellLayout.mainSeparatorThickness }
        set(thickness) {
            self.dayViewCellLayout.mainSeparatorThickness = thickness
            updateLayout()
        }
    }
    /**
    Color of the dashed day view separators.
     */
    var dashedSeparatorColor: UIColor {
        get { self.dayViewCellLayout.dashedSeparatorColor }
        set(color) {
            self.dayViewCellLayout.dashedSeparatorColor = color
            updateLayout()
        }
    }
    /**
     Thickness of the dashed day view separators.
     */
    var dashedSeparatorThickness: CGFloat {
        get { self.dayViewCellLayout.dashedSeparatorThickness }
        set(thickness) {
            self.dayViewCellLayout.dashedSeparatorThickness = thickness
            updateLayout()
        }
    }
    /**
    Pattern of the dashed day view separators.
     */
    var dashedSeparatorPattern: [NSNumber] {
        get { self.dayViewCellLayout.dashedSeparatorPattern }
        set(pattern) {
            self.dayViewCellLayout.dashedSeparatorPattern = pattern
            updateLayout()
        }
    }
    /**
     Determines style the event layers
     */
    var eventStyleCallback: EventStlyeCallback? {
        get { self.dayViewCellLayout.eventStyleCallback }
        set(callback) {
            self.dayViewCellLayout.eventStyleCallback = callback
            updateLayout()
        }
    }
}

// MARK: - SCROLLVIEW LAYOUT VARIABLES -

struct LayoutVariables {

    // MARK: - FONT & COLOUR VARIABLES -

    // Color for day view default color
    fileprivate(set) static var defaultDayViewColor = LayoutDefaults.defaultDayViewColor
    // Color for day view weekend color
    fileprivate(set) static var weekendDayViewColor = LayoutDefaults.weekendDayViewColor
    // Color for day view passed color
    fileprivate(set) static var passedDayViewColor = LayoutDefaults.passedDayViewColor
    // Color for day view passed weekend color
    fileprivate(set) static var passedWeekendDayViewColor = LayoutDefaults.passedWeekendDayViewColor
    // Color for today
    fileprivate(set) static var todayViewColor = LayoutDefaults.todayViewColor

    // Color for day view hour indicator
    fileprivate(set) static var hourIndicatorColor = LayoutDefaults.hourIndicatorColor
    // Thickness for day view hour indicator
    fileprivate(set) static var hourIndicatorThickness = LayoutDefaults.hourIndicatorThickness

    // Color for day view main separators
    fileprivate(set) static var mainSeparatorColor = LayoutDefaults.backgroundColor
    // Thickness for day view main Separators
    fileprivate(set) static var mainSeparatorThickness = LayoutDefaults.mainSeparatorThickness

    // Color for day view dahshed Separators
    fileprivate(set) static var dashedSeparatorColor = LayoutDefaults.backgroundColor
    // Thickness for day view dashed Separators
    fileprivate(set) static var dashedSeparatorThickness = LayoutDefaults.dashedSeparatorThickness
    // Pattern for day view dashed Separators
    fileprivate(set) static var dashedSeparatorPattern = LayoutDefaults.dashedSeparatorPattern

    // Text contained in preview event
    fileprivate(set) static var previewEventText = LayoutDefaults.previewEventText
    // Color of the preview event
    fileprivate(set) static var previewEventColor = LayoutDefaults.previewEventColor
    // Height of the preview event in hours.
    fileprivate(set) static var previewEventHeightInHours = LayoutDefaults.previewEventHeightInHours
    // Number of minutes the preview event will snap to.
    fileprivate(set) static var previewEventPrecisionInMinutes = LayoutDefaults.previewEventPrecisionInMinutes
    // Show preview on long press.
    fileprivate(set) static var showPreviewOnLongPress = LayoutDefaults.showPreviewOnLongPress
}

extension TextVariables {
    // Font for all event labels
    public fileprivate(set) static var eventLabelFont = LayoutDefaults.eventLabelFont
    // Font for all event labels
    public fileprivate(set) static var eventLabelInfoFont = LayoutDefaults.eventLabelThinFont
    // Text color for all event labels
    fileprivate(set) static var eventLabelTextColor = LayoutDefaults.eventLabelTextColor
    // Stores if event label resizing is enabled
    fileprivate(set) static var eventLabelFontResizingEnabled = false
    // Horizontal padding of text in event labels
    fileprivate(set) static var eventLabelHorizontalTextPadding = LayoutDefaults.eventLabelHorizontalTextPadding
    // Vertical padding of text in event labels
    fileprivate(set) static var eventLabelVerticalTextPadding = LayoutDefaults.eventLabelVerticalTextPadding
}
