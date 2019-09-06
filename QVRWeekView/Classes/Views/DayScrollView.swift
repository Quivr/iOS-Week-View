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
    var weekView: WeekView? {
        return self.superview?.superview as? WeekView
    }

    // Percentual offset at the top of the current DayScrollView
    var topOffset: Double {
        get {
            return Double(self.verticalOffset / self.contentSize.height)
        }
        set {
            self.verticalOffset = CGFloat(Double(self.contentSize.height) * newValue)
        }
    }

    // Percentual offset at the bottom of the current DayScrollView
    var bottomOffset: Double {
        get {
            return Double((self.frame.size.height + self.verticalOffset) / self.contentSize.height)
        }
        set {
            self.verticalOffset = CGFloat(Double(self.contentSize.height) * newValue) - LayoutVariables.activeFrameHeight
        }
    }

    // Percentual offset in the center of the current DayScrollView
    var centerOffset: Double {
        get {
            return self.topOffset + Double((LayoutVariables.activeFrameHeight / 2) / self.contentSize.height)
        }
        set {
            self.verticalOffset = CGFloat(Double(self.contentSize.height) * newValue) - LayoutVariables.activeFrameHeight / 2
        }
    }

    // MARK: - INSTANCE VARIABLES -

    // Collection view
    private(set) var dayCollectionView: DayCollectionView!
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
    private var activeYear: Int = DayDate.today.year {
        didSet {
            LayoutVariables.daysInActiveYear = DateSupport.getDaysInYear(activeYear)
        }
    }
    // Current active day
    private(set) var activeDay: DayDate = DayDate.today {
        didSet {
            self.weekView?.activeDayWasChanged(to: self.activeDay)
        }
    }
    // Year todauy
    private var yearToday: Int = DayDate.today.year
    // Current period
    private var currentPeriod: Period = Period(ofDate: DayDate.today)
    // Bool stores is view is scrolling to a specific day
    private var scrollingToDay: Bool = false
    // Previous zoom scale of content
    private var previousZoomTouch: CGPoint?
    // Current zoom scale of content
    private var lastTouchZoomScale = CGFloat(1)
    // Offset added to the offset when displaying now
    private static let showNowOffset = 0.005

    // The vertical scrolling offset of the current DayScrollView.
    private var verticalOffset: CGFloat {
        get {
            return self.contentOffset.y
        }
        set {
            let offset = newValue > LayoutVariables.maxOffsetY
                ? LayoutVariables.maxOffsetY
                : (newValue < LayoutVariables.minOffsetY ? LayoutVariables.minOffsetY : newValue)
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

        // Set visible days variable for device orientation
        LayoutVariables.orientation = UIApplication.shared.statusBarOrientation
        LayoutVariables.activeFrameWidth = self.frame.width
        LayoutVariables.activeFrameHeight = self.frame.height

        // Make day collection view and add it to frame
        dayCollectionView = DayCollectionView(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: self.bounds.width,
                                                            height: LayoutVariables.totalContentHeight),
                                              collectionViewLayout: DayCollectionViewFlowLayout())
        dayCollectionView.contentOffset = CGPoint(x: calcXOffset(forDay: DayDate.today.dayInYear), y: 0)
        dayCollectionView.contentSize = CGSize(width: LayoutVariables.totalContentWidth, height: LayoutVariables.totalContentHeight)
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
        if self.frame.width != LayoutVariables.activeFrameWidth || self.frame.height != LayoutVariables.activeFrameHeight {
            updateLayout()
        }
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
            if collectionView.contentOffset.x < LayoutVariables.minOffsetX {
                resetView(withYearOffsetChange: -1)
            }
            else if collectionView.contentOffset.x > LayoutVariables.maxOffsetX {
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
        return LayoutVariables.collectionViewCellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dayViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellKeys.dayViewCell, for: indexPath) as? DayViewCell {
            dayViewCell.clearValues()
            dayViewCell.delegate = self
            dayViewCell.eventStyleCallback = self.weekView?.eventStyleCallback
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
            let yOffset = LayoutVariables.totalContentHeight*time.getPercentDayPassed()-(LayoutVariables.activeFrameHeight/2)
            let minOffsetY = LayoutVariables.minOffsetY
            let maxOffsetY = LayoutVariables.maxOffsetY
            self.setContentOffset(CGPoint(x: 0, y: yOffset < minOffsetY ? minOffsetY : (yOffset > maxOffsetY ? maxOffsetY : yOffset)), animated: true)
        }
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter: CGPoint?, andState state: UIGestureRecognizer.State) {

        // Store previous zoom scale
        let previousZoom = LayoutVariables.zoomScale

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
        if currentZoom < LayoutVariables.minimumZoomScale {
            currentZoom = LayoutVariables.minimumZoomScale
        }
        else if currentZoom > LayoutVariables.maximumZoomScale {
            currentZoom = LayoutVariables.maximumZoomScale
        }
        self.setCurrentZoomScale(to: currentZoom)

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
        if newYOffset < LayoutVariables.minOffsetY {
            newYOffset = LayoutVariables.minOffsetY
        }
        else if newYOffset > LayoutVariables.maxOffsetY {
            newYOffset = LayoutVariables.maxOffsetY
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
            let possibleSplitEvents = eventData.checkForSplitting()
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
            for (date, calc) in frameCalculators where date < startDate || date > endDate {
                calc.cancelCalculation()
            }
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

        // Update layout variables
        LayoutVariables.activeFrameWidth = self.frame.width
        LayoutVariables.activeFrameHeight = self.frame.height
        LayoutVariables.orientation = UIApplication.shared.statusBarOrientation
        // Update scroll view content size
        self.contentSize = CGSize(width: LayoutVariables.activeFrameWidth, height: LayoutVariables.totalContentHeight)

        // Update size of day view cells
        updateDayViewCellSizeAndSpacing()
        // Update frame of day collection view
        dayCollectionView.frame = CGRect(x: 0, y: 0, width: LayoutVariables.activeFrameWidth, height: LayoutVariables.totalContentHeight)

        if oldWidth != LayoutVariables.totalContentWidth {
            dayCollectionView.contentOffset = CGPoint(x: calcXOffset(forDay: activeDay.dayInYear), y: 0)
        } else {
            dayCollectionView.contentOffset = CGPoint(x: oldXOffset, y: 0)
        }

        // Update content size
        dayCollectionView.contentSize = CGSize(width: LayoutVariables.totalContentWidth, height: LayoutVariables.totalContentHeight)

        self.weekView?.updateVisibleLabelsAndMainConstraints()
    }

    private func resetView(withYearOffsetChange change: Int) {
        activeYear += change

        if change < 0 {
            dayCollectionView.contentOffset.x = LayoutVariables.maxOffsetX
        } else if change > 0 {
            dayCollectionView.contentOffset.x = LayoutVariables.minOffsetX
        }
    }

    private func scrollToNearestCell() {

        let xOffset = dayCollectionView.contentOffset.x
        let yOffset = dayCollectionView.contentOffset.y

        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)

        if truncatedToPagingWidth >= 0.5 && yOffset >= LayoutVariables.minOffsetY && yOffset <= LayoutVariables.maxOffsetY {
            dayCollectionView.setContentOffset(CGPoint(x: calcXOffset(forDay: round(xOffset / totalDayViewWidth)),
                                                       y: dayCollectionView.contentOffset.y), animated: true)
        }
    }

    private func updateDayViewCellSizeAndSpacing() {
        if let flowLayout = dayCollectionView.collectionViewLayout as? DayCollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.dayViewCellHeight)
            flowLayout.minimumLineSpacing = LayoutVariables.dayViewHorizontalSpacing
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
        return day * LayoutVariables.totalDayViewCellWidth
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
     Sets the number of days visible in the week view when in portrait mode.
     */
    func setVisiblePortraitDays(to days: CGFloat) -> Bool {

        // Set portrait visisble days variable
        LayoutVariables.portraitVisibleDays = days
        if LayoutVariables.orientation.isPortrait {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the number of days visible in the week view when in landscape mode.
     */
    func setVisibleLandscapeDays(to days: CGFloat) -> Bool {
        LayoutVariables.landscapeVisibleDays = days
        if LayoutVariables.orientation.isLandscape {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the default font for event labels.
     */
    func setEventLabelFont(to font: UIFont) {
        TextVariables.eventLabelFont = font
        updateLayout()
    }

    /**
     Sets the thin font for event labels.
     */
    func setEventLabelInfoFont(to font: UIFont) {
        TextVariables.eventLabelInfoFont = font
        updateLayout()
    }

    /**
     Sets the text color for event labels.
     */
    func setEventLabelTextColor(to color: UIColor) {
        TextVariables.eventLabelTextColor = color
        updateLayout()
    }

    /**
     Sets the minimum scale for day labels.
     */
    func setEventLabelMinimumFontSize(to size: CGFloat) {
        TextVariables.eventLabelMinimumFontSize = size
        updateLayout()
    }

    /**
     Sets whether event label text should resize or not.
     */
    func setEventLabelFontResizingEnabled(to bool: Bool) {
        TextVariables.eventLabelFontResizingEnabled = bool
        updateLayout()
    }

    /**
     Sets the horizontal padding of the text within event labels.
     */
    func setEventLabelHorizontalTextPadding(to padding: CGFloat) {
        TextVariables.eventLabelHorizontalTextPadding = padding
        updateLayout()
    }

    /**
     Sets the vertical padding of the text within event labels.
     */
    func setEventLabelVerticalTextPadding(to padding: CGFloat) {
        TextVariables.eventLabelVerticalTextPadding = padding
        updateLayout()
    }

    /**
     Sets the text of the preview event.
     */
    func setPreviewEventText(to text: String) {
        LayoutVariables.previewEventText = text
        updateLayout()
    }

    /**
     Sets the color of the preview event.
     */
    func setPreviewEventColor(to color: UIColor) {
        LayoutVariables.previewEventColor = color
        updateLayout()
    }

    /**
     Sets the text of the preview event.
     */
    func setPreviewEventHeightInHours(to height: Double) {
        LayoutVariables.previewEventHeightInHours = height
        updateLayout()
    }

    /**
     Sets the precision of the preview event.
     */
    func setPreviewEventPrecisionInMinutes(to minutes: Double) {
        LayoutVariables.previewEventPrecisionInMinutes = minutes
        updateLayout()
    }

    /**
     Sets show preview on long press.
     */
    func setShowPreviewOnLongPress(to show: Bool) {
        LayoutVariables.showPreviewOnLongPress = show
    }

    /**
     Sets the color of default day view color.
     */
    func setDefaultDayViewColor(to color: UIColor) {
        LayoutVariables.defaultDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of weekend day view color.
     */
    func setWeekendDayViewColor(to color: UIColor) {
        LayoutVariables.weekendDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of default day view color.
     */
    func setPassedDayViewColor(to color: UIColor) {
        LayoutVariables.passedDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of weekend day view color.
     */
    func setPassedWeekendDayViewColor(to color: UIColor) {
        LayoutVariables.passedWeekendDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of today's view.
     */
    func setTodayViewColor(to color: UIColor) {
        LayoutVariables.todayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of day view hour indicators.
     */
    func setDayViewHourIndicatorColor(to color: UIColor) {
        LayoutVariables.hourIndicatorColor = color
        updateLayout()
    }

    /**
     Sets the thickness of day view hour indicators.
     */
    func setDayViewHourIndicatorThickness(to thickness: CGFloat) {
        LayoutVariables.hourIndicatorThickness = thickness
        updateLayout()
    }

    /**
     Sets the color of the main day view separators.
     */
    func setDayViewMainSeparatorColor(to color: UIColor) {
        LayoutVariables.mainSeparatorColor = color
        updateLayout()
    }

    /**
     Sets the thickness of the main day view separators.
     */
    func setDayViewMainSeparatorThickness(to thickness: CGFloat) {
        LayoutVariables.mainSeparatorThickness = thickness
        updateLayout()
    }

    /**
     Sets the color of the dashed day view separators.
     */
    func setDayViewDashedSeparatorColor(to color: UIColor) {
        LayoutVariables.dashedSeparatorColor = color
        updateLayout()
    }

    /**
     Sets the thickness of the dashed day view separators.
     */
    func setDayViewDashedSeparatorThickness(to thickness: CGFloat) {
        LayoutVariables.dashedSeparatorThickness = thickness
        updateLayout()
    }

    /**
     Sets the thickness of the dashed day view separators.
     */
    func setDayViewDashedSeparatorPattern(to pattern: [NSNumber]) {
        LayoutVariables.dashedSeparatorPattern = pattern
        updateLayout()
    }

    /**
     Sets the height of the day view cells for zoom scale 1.
     */
    func setInitialVisibleDayViewCellHeight(to height: CGFloat) {
        LayoutVariables.initialDayViewCellHeight = height
        updateLayout()
    }

    /**
     Sets the spacing in between day view cells for portrait mode.
     */
    func setPortraitDayViewHorizontalSpacing(to width: CGFloat) -> Bool {
        LayoutVariables.portraitDayViewHorizontalSpacing = width
        if LayoutVariables.orientation.isPortrait {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the spacing in between day view cells for landscape mode.
     */
    func setLandscapeDayViewHorizontalSpacing(to width: CGFloat) -> Bool {
        LayoutVariables.landscapeDayViewHorizontalSpacing = width
        if LayoutVariables.orientation.isLandscape {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the spacing in between day view cells for portrait mode.
     */
    func setPortraitDayViewVerticalSpacing(to width: CGFloat) -> Bool {
        LayoutVariables.portraitDayViewVerticalSpacing = width
        if LayoutVariables.orientation.isPortrait {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the spacing in between day view cells for landscape mode.
     */
    func setLandscapeDayViewVerticalSpacing(to width: CGFloat) -> Bool {
        LayoutVariables.landscapeDayViewVerticalSpacing = width
        if LayoutVariables.orientation.isLandscape {
            updateLayout()
            return true
        }
        return false
    }

    /**
     */
    func setMinimumZoomScale(to scale: CGFloat) {
        LayoutVariables.minimumZoomScale = scale
    }

    /**
     */
    func setCurrentZoomScale(to scale: CGFloat) {
        LayoutVariables.zoomScale = scale
        updateLayout()
    }

    /**
     */
    func setMaximumZoomScale(to scale: CGFloat) {
        LayoutVariables.maximumZoomScale = scale
    }

    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setVelocityOffsetMultiplier(to multiplier: CGFloat) {
        LayoutVariables.velocityOffsetMultiplier = multiplier
    }

    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setAllDayEventHeight(to height: CGFloat) {
        LayoutVariables.allDayEventHeight = height
        updateLayout()
    }

    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setAllDayEventVerticalSpacing(to height: CGFloat) {
        LayoutVariables.allDayEventVerticalSpacing = height
        updateLayout()
    }

    /**
     Sets spread all day events on x axis, if not true than spread will be made on y axis.
     */
    func setAllDayEventsSpreadOnX(to onX: Bool) {
        LayoutVariables.allDayEventsSpreadOnX = onX
    }

}

// MARK: - SCROLLVIEW LAYOUT VARIABLES -

struct LayoutVariables {

    // MARK: - SCROLLVIEW LAYOUT & SPACING VARIABLES -

    fileprivate(set) static var orientation: UIInterfaceOrientation = .portrait {
        didSet {
            updateOrientationValues()
        }
    }

    fileprivate(set) static var activeFrameWidth = CGFloat(250) {
        didSet {
            updateDayViewCellWidth()
        }
    }

    fileprivate(set) static var activeFrameHeight = CGFloat(500) {
        didSet {
            updateMaxOffsetY()
        }
    }

    // Zoom scale of current layout
    fileprivate(set) static var zoomScale = CGFloat(1) {
        didSet {
            updateDayViewCellHeight()
        }
    }

    // Number of day columns visible depending on device orientation
    private(set) static var visibleDays: CGFloat = LayoutDefaults.visibleDaysPortrait {
        didSet {
            updateDayViewCellWidth()
        }
    }
    // Width of spacing between day columns in landscape mode
    private(set) static var dayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing {
        didSet {
            updateDayViewCellWidth()
        }
    }
    // Width of spacing between day columns in landscape mode
    private(set) static var dayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing {
        didSet {
            updateTotalContentHeight()
        }
    }

    // Height of the initial day columns
    fileprivate(set) static var initialDayViewCellHeight = LayoutDefaults.dayViewCellHeight {
        didSet {
            updateDayViewCellHeight()
        }
    }
    // Height of the current day columns
    private(set) static var dayViewCellHeight = LayoutDefaults.dayViewCellHeight {
        didSet {
            updateTotalContentHeight()
        }
    }

    // Width of an entire day column
    private(set) static var dayViewCellWidth = (activeFrameWidth - dayViewHorizontalSpacing*(visibleDays-1)) / visibleDays {
        didSet {
            updateTotalDayViewCellWidth()
        }
    }

    // Total width of an entire day column including spacing
    private(set) static var totalDayViewCellWidth = dayViewCellWidth + dayViewHorizontalSpacing {
        didSet {
            updateMaxOffsetX()
            updateTotalContentWidth()
        }
    }

    // Visible day cells in protrait mode
    fileprivate(set) static var portraitVisibleDays = LayoutDefaults.visibleDaysPortrait {
        didSet {
            updateMaximumVisibleDays()
        }
    }
    // Visible day cells in landscape mode
    fileprivate(set) static var landscapeVisibleDays = LayoutDefaults.visibleDaysLandscape {
        didSet {
            updateMaximumVisibleDays()
        }
    }

    // Number of days in current year being displayed
    fileprivate(set) static var daysInActiveYear = DateSupport.getDaysInYear(DayDate.today.year) {
        didSet {
            updateCollectionViewCellCount()
            updateMaxOffsetX()
        }
    }

    // Collection view cell count buffer, number of cells to de added to the "right" side of the colelction view.
    // This is equal to maximum number of days visisble plus one. This allows for smooth scrolling when crossing the year mark.
    private(set) static var collectionViewCellCountBuffer = Int(max(portraitVisibleDays, landscapeVisibleDays))+1 {
        didSet {
            updateCollectionViewCellCount()
        }
    }

    // Number of cells in the collection view
    private(set) static var collectionViewCellCount = daysInActiveYear + collectionViewCellCountBuffer {
        didSet {
            updateTotalContentWidth()
        }
    }

    // Width of spacing between day columns in portrait mode
    fileprivate(set) static var portraitDayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing {
        didSet {
            updateOrientationValues()
        }
    }
    // Width of spacing between day columns in landscape mode
    fileprivate(set) static var landscapeDayViewHorizontalSpacing = LayoutDefaults.landscapeDayViewHorizontalSpacing {
        didSet {
            updateOrientationValues()
        }
    }

    // Width of spacing between day columns in portrait mode
    fileprivate(set) static var portraitDayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing {
        didSet {
            updateOrientationValues()
        }
    }
    // Width of spacing between day columns in landscape mode
    fileprivate(set) static var landscapeDayViewVerticalSpacing = LayoutDefaults.landscapeDayViewVerticalSpacing {
        didSet {
            updateOrientationValues()
        }
    }

    // Height of all scrollable content
    private(set) static var totalContentHeight = dayViewVerticalSpacing*2 + dayViewCellHeight {
        didSet {
            updateMaxOffsetY()
        }
    }

    // Height of all scrollable content
    private(set) static var totalContentWidth = CGFloat(collectionViewCellCount)*totalDayViewCellWidth+dayViewHorizontalSpacing

    // Minimum zoom scale value
    fileprivate(set) static var minimumZoomScale = LayoutDefaults.minimumZoom
    // Maximum zoom scale valueapp store
    fileprivate(set) static var maximumZoomScale = LayoutDefaults.maximumZoom
    // Min x-axis values that repeating starts at
    private(set) static var minOffsetX = CGFloat(0)
    // Max x-axis values that repeating starts at
    private(set) static var maxOffsetX = CGFloat(daysInActiveYear)*totalDayViewCellWidth
    // Min y-axis values that can be scrolled to
    private(set) static var minOffsetY = CGFloat(0)
    // Max y-axis values that can be scrolled to
    private(set) static var maxOffsetY = totalContentHeight - activeFrameHeight {
        didSet {
            if maxOffsetY < minOffsetY {
                maxOffsetY = minOffsetY
            }
        }
    }
    // Velocity multiplier for pagin
    fileprivate(set) static var velocityOffsetMultiplier = LayoutDefaults.velocityOffsetMultiplier
    // Height of an all day event
    fileprivate(set) static var allDayEventHeight = LayoutDefaults.allDayEventHeight
    // Vertical spacing of an all day event
    fileprivate(set) static var allDayEventVerticalSpacing = LayoutDefaults.allDayVerticalSpacing
    // Spread all day events on x axis, if not true than spread will be made on y axis
    fileprivate(set) static var allDayEventsSpreadOnX = LayoutDefaults.allDayEventsSpreadOnX

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

    // MARK: - UPDATE FUNCTIONS -

    private static func updateOrientationValues() {
        if orientation.isPortrait {
            visibleDays = portraitVisibleDays
            dayViewHorizontalSpacing = portraitDayViewHorizontalSpacing
            dayViewVerticalSpacing = portraitDayViewVerticalSpacing
        }
        else if orientation.isLandscape {
            visibleDays = landscapeVisibleDays
            dayViewHorizontalSpacing = landscapeDayViewHorizontalSpacing
            dayViewVerticalSpacing = landscapeDayViewVerticalSpacing
        }
    }

    private static func updateDayViewCellWidth() {
        dayViewCellWidth = (activeFrameWidth - dayViewHorizontalSpacing*(visibleDays-1)) / visibleDays
    }

    private static func updateDayViewCellHeight() {
        dayViewCellHeight = initialDayViewCellHeight*zoomScale
    }

    private static func updateTotalDayViewCellWidth() {
        totalDayViewCellWidth = dayViewCellWidth + dayViewHorizontalSpacing
    }

    private static func updateTotalContentHeight() {
        totalContentHeight = dayViewVerticalSpacing*2 + dayViewCellHeight
    }

    private static func updateTotalContentWidth() {
        totalContentWidth = CGFloat(collectionViewCellCount)*totalDayViewCellWidth-dayViewHorizontalSpacing
    }

    private static func updateMaximumVisibleDays() {
        collectionViewCellCountBuffer = Int(max(portraitVisibleDays, landscapeVisibleDays))
    }

    private static func updateCollectionViewCellCount() {
        collectionViewCellCount = collectionViewCellCountBuffer + daysInActiveYear
    }

    private static func updateMaxOffsetX() {
        maxOffsetX = CGFloat(daysInActiveYear)*totalDayViewCellWidth
    }

    private static func updateMaxOffsetY() {
        maxOffsetY = totalContentHeight - activeFrameHeight
    }
}

extension TextVariables {
    // Font for all event labels
    public fileprivate(set) static var eventLabelFont = LayoutDefaults.eventLabelFont
    // Font for all event labels
    public fileprivate(set) static var eventLabelInfoFont = LayoutDefaults.eventLabelThinFont
    // Text color for all event labels
    fileprivate(set) static var eventLabelTextColor = LayoutDefaults.eventLabelTextColor
    // Minimum scaling for all event labels
    fileprivate(set) static var eventLabelMinimumFontSize = LayoutDefaults.eventLabelMinimumFontSize
    // Stores if event label resizing is enabled
    fileprivate(set) static var eventLabelFontResizingEnabled = false
    // Horizontal padding of text in event labels
    fileprivate(set) static var eventLabelHorizontalTextPadding = LayoutDefaults.eventLabelHorizontalTextPadding
    // Vertical padding of text in event labels
    fileprivate(set) static var eventLabelVerticalTextPadding = LayoutDefaults.eventLabelVerticalTextPadding
}
