import Foundation
import UIKit

// MARK: - DAY SCROLL VIEW -

/**
 Class of the scroll view contained within the WeekView.
 */
class DayScrollView: UIScrollView, UIScrollViewDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, DayViewCellDelegate, FrameCalculatorDelegate {

    // MARK: - INSTANCE VARIABLES -

    var layoutVariables = LayoutVariables()

    // Collection view
    private(set) var dayCollectionView: DayCollectionView!
    // All eventData objects
    private(set) var allEventsData: [DayDate: [String: EventData]] = [:]
    // All event framesAll
    private(set) var allEventFrames: [DayDate: [String: CGRect]] = [:]
    // All fullday events
    private var allDayEvents: [DayDate: [EventData]] = [:]
    // All active dayViewCells
    private var dayViewCells: [Int: DayViewCell] = [:]
    // All frame calculators
    private var frameCalculators: [DayDate: FrameCalculator] = [:]
    // Active year on view
    private var activeYear: Int = DayDate.today.year {
        didSet {
            layoutVariables.daysInActiveYear = DateSupport.getDaysInYear(activeYear)
        }
    }
    // Current active day
    private var activeDay: DayDate = DayDate.today {
        didSet {
            if let weekView = self.superview?.superview as? WeekView {
                weekView.activeDayWasChanged(to: self.activeDay)
            }
        }
    }
    // Year todauy
    private var yearToday: Int = DayDate.today.year
    // Current period
    private var currentPeriod: Period = Period(ofDate: DayDate.today)
    // Bool stores if event thread is running
    private var eptRunning: Bool = false
    // Bool stores if event thread should stop
    private var eptSafeContinue: Bool = false
    // Bool stores is view is scrolling to a specific day
    private var scrollingToDay: Bool = false
    // Stores most recently assigned event data
    private var eptTempData: [EventData]?
    // Previous zoom scale of content
    private var previousZoomTouch: CGPoint?
    // Current zoom scale of content
    private var lastTouchZoomScale = CGFloat(1)

    // Fix for full day event after rotation of the device
    // When device is rotated all day events are moved out of the frame,
    // since they are build not using autolayout
    private var screenWidth = CGFloat(0)

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
        layoutVariables.orientation = UIApplication.shared.statusBarOrientation
        layoutVariables.activeFrameWidth = self.frame.width
        layoutVariables.activeFrameHeight = self.frame.height

        // Make day collection view and add it to frame
        dayCollectionView = DayCollectionView(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: self.bounds.width,
                                                            height: layoutVariables.totalContentHeight),
                                              collectionViewLayout: DayCollectionViewFlowLayout(layoutVariables: layoutVariables))
        dayCollectionView.contentOffset = CGPoint(x: layoutVariables.totalDayViewCellWidth*CGFloat(DayDate.today.dayInYear), y: 0)
        dayCollectionView.contentSize = CGSize(width: layoutVariables.totalContentWidth, height: layoutVariables.totalContentHeight)
        dayCollectionView.delegate = self
        dayCollectionView.dataSource = self
        self.addSubview(dayCollectionView)

        // Set content size for vertical scrolling
        self.contentSize = CGSize(width: self.bounds.width, height: dayCollectionView.frame.height)
        self.contentOffset = CGPoint(x: 0, y: layoutVariables.dayViewCellHeight*DateSupport.getPercentTodayPassed())

        // Add tap gesture recognizer
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))

        // Set scroll view properties
        self.isDirectionalLockEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
    }

    override func layoutSubviews() {

        if self.frame.width != layoutVariables.activeFrameWidth || self.frame.height != layoutVariables.activeFrameHeight {
            updateLayout()
        }
    }

    // MARK: - GESTURE, SCROLL & DATA SOURCE FUNCTIONS -

    func tap(_ sender: UITapGestureRecognizer) {

        if !self.dayCollectionView.isDragging && !self.dayCollectionView.isDecelerating {
            scrollToNearestCell()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Handle side and top bar animations
        if let weekView = self.superview?.superview as? WeekView {
            weekView.updateTopAndSideBarPositions()
        }

        if let collectionView = scrollView as? DayCollectionView {
            if collectionView.contentOffset.x < layoutVariables.minOffsetX {
                resetView(withYearOffsetChange: -1)
            }
            else if collectionView.contentOffset.x > layoutVariables.maxOffsetX {
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
            scrollToNearestCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layoutVariables.collectionViewCellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dayViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellKeys.dayViewCell, for: indexPath) as? DayViewCell {
            dayViewCell.clearValues()
            dayViewCell.delegate = self
            dayViewCells[dayViewCell.id] = dayViewCell
            let dayDateForCell = getDayDate(forIndexPath: indexPath)
            dayViewCell.setDate(as: dayDateForCell)
            if let eventDataForCell = allEventsData[dayDateForCell], let eventFramesForCell = allEventFrames[dayDateForCell] {
                dayViewCell.setEventsData(eventDataForCell, andFrames: eventFramesForCell)
            }
            return dayViewCell
        }
        return UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let weekView = self.superview?.superview as? WeekView, let dayViewCell = cell as? DayViewCell {
            let dayDate = dayViewCell.date
            weekView.addDayLabel(forIndexPath: indexPath, withDate: dayDate)
            if let allDayEvents = allDayEvents[dayDate] {
                weekView.addAllDayEvents(allDayEvents, forIndexPath: indexPath, withDate: dayDate)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let weekView = self.superview?.superview as? WeekView, let dayViewCell = cell as? DayViewCell {
            let dayDate = dayViewCell.date
            weekView.discardDayLabel(withDate: dayDate)
            if weekView.hasAllDayEvents(forDate: dayDate) {
                weekView.removeAllDayEvents(forDate: dayDate)
            }
        }
    }

    func eventViewWasTappedIn(_ dayViewCell: DayViewCell, withEventData eventData: EventData) {
        if let weekView = self.superview?.superview as? WeekView {
            weekView.eventViewWasTapped(eventData)
        }
    }

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell, hours: Int, minutes: Int) {
        if let weekView = self.superview?.superview as? WeekView {
            weekView.dayViewCellWasLongPressed(dayViewCell, at: hours, and: minutes)
            for (_, dayViewCell) in dayViewCells {
                dayViewCell.addingEvent = true
            }
        }
    }

    func layoutVariables(for dayViewCell: DayViewCell) -> LayoutVariables {
        return layoutVariables
    }

    // solution == nil => do not render events. solution.isEmpty => render empty
    func passSolution(fromCalculator calculator: FrameCalculator, solution: [String: CGRect]?) {
        let date = calculator.date
        allEventFrames[date] = solution
        frameCalculators[date] = nil
        for (_, dayViewCell) in dayViewCells where dayViewCell.date == date {
            if let eventsData = allEventsData[date], let eventFrames = allEventFrames[date] {
                dayViewCell.setEventsData(eventsData, andFrames: eventFrames)
            }
            else if solution != nil {
                dayViewCell.setEventsData([:], andFrames: [:])
            }
        }
    }

    // MARK: - INTERNAL FUNCTIONS -

    func goToAndShow(dayDate: DayDate, showTime: Date? = nil) {
        let animated = dayDate.year == activeYear
        activeYear = dayDate.year
        currentPeriod = Period(ofDate: dayDate)
        activeDay = dayDate
        if animated {
            scrollingToDay = true
        }
        dayCollectionView.setContentOffset(CGPoint(x: CGFloat(dayDate.dayInYear)*layoutVariables.totalDayViewCellWidth,
                                                   y: 0),
                                           animated: animated)
        if !animated {
            requestEvents()
        }
        dayCollectionView.reloadData()

        if let time = showTime {
            let yOffset = layoutVariables.totalContentHeight*time.getPercentDayPassed()-(layoutVariables.activeFrameHeight/2)
            let minOffsetY = layoutVariables.minOffsetY
            let maxOffsetY = layoutVariables.maxOffsetY
            self.setContentOffset(CGPoint(x: 0, y: yOffset < minOffsetY ? minOffsetY : (yOffset > maxOffsetY ? maxOffsetY : yOffset)), animated: true)
        }
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter: CGPoint?, andState state: UIGestureRecognizerState) {

        // Store previous zoom scale
        let previousZoom = layoutVariables.zoomScale

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
        if currentZoom < layoutVariables.minimumZoomScale {
            currentZoom = layoutVariables.minimumZoomScale
        }
        else if currentZoom > layoutVariables.maximumZoomScale {
            currentZoom = layoutVariables.maximumZoomScale
        }
        layoutVariables.zoomScale = currentZoom
        // Update the height and contents of the visible day views
        updateLayout()
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
        if newYOffset < layoutVariables.minOffsetY {
            newYOffset = layoutVariables.minOffsetY
        }
        else if newYOffset > layoutVariables.maxOffsetY {
            newYOffset = layoutVariables.maxOffsetY
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

        if eptRunning {
            eptTempData = eventsData
            eptSafeContinue = false
            return
        }
        else {
            eptRunning = true
            eptSafeContinue = true
        }
        DispatchQueue.global(qos: .userInitiated).async {

            // New eventsdata
            var newEventsData: [DayDate: [String: EventData]] = [:]
            // New all day events
            var newAllDayEvents: [DayDate: [EventData]] = [:]
            // Stores the days which will be changed
            var changedDayDates = Set<DayDate>()

            // Process raw event data and sort it into the allEventsData dictionary. Also check to see which
            // days have had any changes done to them to queue them up for processing.
            for eventData in eventsData {
                guard self.eptSafeContinue else {
                    self.safeCallbackOverwriteAllEvents()
                    return
                }
                let possibleSplitEvents = eventData.checkForSplitting()
                for (dayDate, event) in possibleSplitEvents {
                    if event.allDay {
                        newAllDayEvents.addEvent(event, onDay: dayDate)
                    }
                    else {
                        if !changedDayDates.contains(dayDate) &&
                            Util.isEvent(event, fromDay: dayDate, notInOrHasChanged: self.allEventsData) {
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
            for (dayDate, oldEvents) in self.allEventsData where !changedDayDates.contains(dayDate) && activeDates.contains(dayDate) {
                for (_, oldEvent) in oldEvents where Util.isEvent(oldEvent, fromDay: dayDate, notInOrHasChanged: newEventsData) {
                    changedDayDates.insert(dayDate)
                    break
                }
            }

            guard self.eptSafeContinue else {
                self.safeCallbackOverwriteAllEvents()
                return
            }

            let sortedChangedDays = changedDayDates.sorted { (smaller, larger) -> Bool in
                let diff1 = abs(smaller.dayInYear - self.activeDay.dayInYear)
                let diff2 = abs(larger.dayInYear - self.activeDay.dayInYear)
                return diff1 == diff2 ? smaller > larger : diff1 < diff2
            }

            // Safe exit
            DispatchQueue.main.sync {
                self.eptRunning = false
                self.eptSafeContinue = false
                self.allEventsData = newEventsData
                self.allDayEvents = newAllDayEvents
                if let weekView = self.superview?.superview as? WeekView {
                    for cell in self.dayCollectionView.visibleCells {
                        if let dayViewCell = cell as? DayViewCell {
                            let dayDate = dayViewCell.date
                            let allThisDayEvents = self.allDayEvents[dayDate]
                            if allThisDayEvents == nil && weekView.hasAllDayEvents(forDate: dayDate) {
                                weekView.removeAllDayEvents(forDate: dayDate)
                                dayViewCell.setNeedsLayout()
                            }
                            else if allThisDayEvents != nil {
                                weekView.addAllDayEvents(allThisDayEvents!, forIndexPath: self.dayCollectionView.indexPath(for: cell)!, withDate: dayDate)
                                dayViewCell.setNeedsLayout()
                            }
                        }
                    }
                }
                // Process events for days with changed data
                for dayDate in sortedChangedDays {
                    self.processEventsData(forDayDate: dayDate)
                }
                // Redraw days with no changed data
                for (_, dayViewCell) in self.dayViewCells where !sortedChangedDays.contains(dayViewCell.date) {
                    dayViewCell.setNeedsLayout()
                }
            }
        }
    }

    func requestEvents() {
        if let weekView = self.superview?.superview as? WeekView, !scrollingToDay {
            self.currentPeriod = Period(ofDate: activeDay)
            let startDate = currentPeriod.startDate
            let endDate = currentPeriod.endDate
            for (date, calc) in frameCalculators where date < startDate || date > endDate {
                calc.cancelCalculation()
            }
            weekView.requestEvents(between: startDate, and: endDate)
        }
    }

    // MARK: - HELPER/PRIVATE FUNCTIONS -

    private func safeCallbackOverwriteAllEvents() {
        DispatchQueue.main.sync {
            eptRunning = false
            overwriteAllEvents(withData: eptTempData)
        }
    }

    fileprivate func updateLayout() {

        // Get old offset ratio before resizing cells
        let oldXOffset = dayCollectionView.contentOffset.x
        let oldWidth = dayCollectionView.contentSize.width

        // Update layout variables
        layoutVariables.activeFrameWidth = self.frame.width
        layoutVariables.activeFrameHeight = self.frame.height
        layoutVariables.orientation = UIApplication.shared.statusBarOrientation
        // Update scroll view content size
        self.contentSize = CGSize(width: layoutVariables.activeFrameWidth, height: layoutVariables.totalContentHeight)

        // Update size of day view cells
        updateDayViewCellSizeAndSpacing()
        // Update frame of day collection view
        dayCollectionView.frame = CGRect(x: 0, y: 0, width: layoutVariables.activeFrameWidth, height: layoutVariables.totalContentHeight)

        if oldWidth != layoutVariables.totalContentWidth {
            let newXOffset = CGFloat(CGFloat(activeDay.dayInYear)*layoutVariables.totalDayViewCellWidth).roundUpAdditionalHalf()
            dayCollectionView.contentOffset = CGPoint(x: newXOffset, y: 0)
        }
        else {
            dayCollectionView.contentOffset = CGPoint(x: oldXOffset, y: 0)
        }

        // Update content size
        dayCollectionView.contentSize = CGSize(width: layoutVariables.totalContentWidth, height: layoutVariables.totalContentHeight)

        if let weekView = self.superview?.superview as? WeekView {
            weekView.updateVisibleLabelsAndMainConstraints()

            if screenWidth != frame.width {
                dayCollectionView.reloadData()
                screenWidth = frame.width
            }
        }
    }

    private func resetView(withYearOffsetChange change: Int) {
        activeYear += change

        if change < 0 {
            dayCollectionView.contentOffset.x = (layoutVariables.maxOffsetX).roundDownSubtractedHalf()
        }
        else if change > 0 {
            dayCollectionView.contentOffset.x = (layoutVariables.minOffsetX).roundUpAdditionalHalf()
        }
    }

    private func scrollToNearestCell() {
        let xOffset = dayCollectionView.contentOffset.x
        let yOffset = dayCollectionView.contentOffset.y

        let totalDayViewWidth = layoutVariables.totalDayViewCellWidth
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)

        if truncatedToPagingWidth >= 0.5 && yOffset >= layoutVariables.minOffsetY && yOffset <= layoutVariables.maxOffsetY {
            let targetXOffset = (round(xOffset / totalDayViewWidth)*totalDayViewWidth).roundUpAdditionalHalf()
            dayCollectionView.setContentOffset(CGPoint(x: targetXOffset, y: dayCollectionView.contentOffset.y), animated: true)
        }
    }

    private func updateDayViewCellSizeAndSpacing() {
        if let flowLayout = dayCollectionView.collectionViewLayout as? DayCollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: layoutVariables.dayViewCellWidth, height: layoutVariables.dayViewCellHeight)
            flowLayout.minimumLineSpacing = layoutVariables.dayViewHorizontalSpacing
        }
    }

    private func processEventsData(forDayDate dayDate: DayDate) {
        frameCalculators[dayDate]?.cancelCalculation()
        let calc = FrameCalculator(date: dayDate)
        calc.delegate = self
        frameCalculators[dayDate]?.cancelCalculation()
        frameCalculators[dayDate] = calc
        calc.calculate(withData: allEventsData[dayDate])
    }

    private func updatePeriod() {
        // Set current period to new period
        self.currentPeriod = Period(ofDate: self.activeDay)
        // Load new events for new period
        requestEvents()
    }
}

// MARK: - PERIOD CHANGE ENUM -

private enum PeriodChange {
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
        layoutVariables.portraitVisibleDays = days
        if layoutVariables.orientation.isPortrait {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the number of days visible in the week view when in landscape mode.
     */
    func setVisibleLandscapeDays(to days: CGFloat) -> Bool {
        layoutVariables.landscapeVisibleDays = days
        if layoutVariables.orientation.isLandscape {
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
     Sets if time of events should be shown.
     */
    func setEventShowTimeOfEvent(to showTime: Bool) {
        TextVariables.eventShowTimeOfEvent = showTime
        updateLayout()
    }

    /**
     Sets showing all event's data in one line.
     */
    func setEventsDataInOneLine(to dataInOneLine: Bool) {
        TextVariables.eventsDataInOneLine = dataInOneLine
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
        layoutVariables.previewEventText = text
        updateLayout()
    }

    /**
     Sets the color of the preview event.
     */
    func setPreviewEventColor(to color: UIColor) {
        layoutVariables.previewEventColor = color
        updateLayout()
    }

    /**
     Sets the text of the preview event.
     */
    func setPreviewEventHeightInHours(to height: Double) {
        layoutVariables.previewEventHeightInHours = height
        updateLayout()
    }

    /**
     Sets the precision of the preview event.
     */
    func setPreviewEventPrecisionInMinutes(to minutes: Double) {
        layoutVariables.previewEventPrecisionInMinutes = minutes
        updateLayout()
    }

    /**
     Sets show preview on long press.
     */
    func setShowPreviewOnLongPress(to show: Bool) {
        layoutVariables.showPreviewOnLongPress = show
    }

    /**
     Sets the color of default day view color.
     */
    func setDefaultDayViewColor(to color: UIColor) {
        layoutVariables.defaultDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of weekend day view color.
     */
    func setWeekendDayViewColor(to color: UIColor) {
        layoutVariables.weekendDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of default day view color.
     */
    func setPassedDayViewColor(to color: UIColor) {
        layoutVariables.passedDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of weekend day view color.
     */
    func setPassedWeekendDayViewColor(to color: UIColor) {
        layoutVariables.passedWeekendDayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of today's view.
     */
    func setTodayViewColor(to color: UIColor) {
        layoutVariables.todayViewColor = color
        updateLayout()
    }

    /**
     Sets the color of day view hour indicators.
     */
    func setDayViewHourIndicatorColor(to color: UIColor) {
        layoutVariables.hourIndicatorColor = color
        updateLayout()
    }

    /**
     Sets the thickness of day view hour indicators.
     */
    func setDayViewHourIndicatorThickness(to thickness: CGFloat) {
        layoutVariables.hourIndicatorThickness = thickness
        updateLayout()
    }

    /**
     Sets the color of the main day view separators.
     */
    func setDayViewMainSeparatorColor(to color: UIColor) {
        layoutVariables.mainSeparatorColor = color
        updateLayout()
    }

    /**
     Sets the thickness of the main day view separators.
     */
    func setDayViewMainSeparatorThickness(to thickness: CGFloat) {
        layoutVariables.mainSeparatorThickness = thickness
        updateLayout()
    }

    /**
     Sets the color of the dashed day view separators.
     */
    func setDayViewDashedSeparatorColor(to color: UIColor) {
        layoutVariables.dashedSeparatorColor = color
        updateLayout()
    }

    /**
     Sets the thickness of the dashed day view separators.
     */
    func setDayViewDashedSeparatorThickness(to thickness: CGFloat) {
        layoutVariables.dashedSeparatorThickness = thickness
        updateLayout()
    }

    /**
     Sets the thickness of the dashed day view separators.
     */
    func setDayViewDashedSeparatorPattern(to pattern: [NSNumber]) {
        layoutVariables.dashedSeparatorPattern = pattern
        updateLayout()
    }

    /**
     Sets the height of the day view cells for zoom scale 1.
     */
    func setInitialVisibleDayViewCellHeight(to height: CGFloat) {
        layoutVariables.initialDayViewCellHeight = height
        updateLayout()
    }

    /**
     Sets the spacing in between day view cells for portrait mode.
     */
    func setPortraitDayViewHorizontalSpacing(to width: CGFloat) -> Bool {
        layoutVariables.portraitDayViewHorizontalSpacing = width
        if layoutVariables.orientation.isPortrait {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the spacing in between day view cells for landscape mode.
     */
    func setLandscapeDayViewHorizontalSpacing(to width: CGFloat) -> Bool {
        layoutVariables.landscapeDayViewHorizontalSpacing = width
        if layoutVariables.orientation.isLandscape {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the spacing in between day view cells for portrait mode.
     */
    func setPortraitDayViewVerticalSpacing(to width: CGFloat) -> Bool {
        layoutVariables.portraitDayViewVerticalSpacing = width
        if layoutVariables.orientation.isPortrait {
            updateLayout()
            return true
        }
        return false
    }

    /**
     Sets the spacing in between day view cells for landscape mode.
     */
    func setLandscapeDayViewVerticalSpacing(to width: CGFloat) -> Bool {
        layoutVariables.landscapeDayViewVerticalSpacing = width
        if layoutVariables.orientation.isLandscape {
            updateLayout()
            return true
        }
        return false
    }

    func setMinimumZoomScale(to scale: CGFloat) {
        layoutVariables.minimumZoomScale = scale
    }

    func setMaximumZoomScale(to scale: CGFloat) {
        layoutVariables.maximumZoomScale = scale
    }

    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setVelocityOffsetMultiplier(to multiplier: CGFloat) {
        layoutVariables.velocityOffsetMultiplier = multiplier
    }

    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setAllDayEventHeight(to height: CGFloat) {
        layoutVariables.allDayEventHeight = height
        updateLayout()
    }

    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setAllDayEventVerticalSpacing(to height: CGFloat) {
        layoutVariables.allDayEventVerticalSpacing = height
        updateLayout()
    }

    /**
     Sets spread all day events on x axis, if not true than spread will be made on y axis.
     */
    func setAllDayEventsSpreadOnX(to onX: Bool) {
        layoutVariables.allDayEventsSpreadOnX = onX
    }

}

// MARK: - SCROLLVIEW LAYOUT VARIABLES -

class LayoutVariables {

    // MARK: - SCROLLVIEW LAYOUT & SPACING VARIABLES -

    fileprivate(set) var orientation: UIInterfaceOrientation = .portrait {
        didSet {
            updateOrientationValues()
        }
    }

    fileprivate(set) var activeFrameWidth = CGFloat(250) {
        didSet {
            updateDayViewCellWidth()
        }
    }

    fileprivate(set) var activeFrameHeight = CGFloat(500) {
        didSet {
            updateMaxOffsetY()
        }
    }

    // Zoom scale of current layout
    fileprivate(set) var zoomScale = CGFloat(1) {
        didSet {
            updateDayViewCellHeight()
        }
    }

    // Number of day columns visible depending on device orientation
    private(set) var visibleDays: CGFloat = LayoutDefaults.visibleDaysPortrait {
        didSet {
            updateDayViewCellWidth()
        }
    }

    // Width of spacing between day columns in landscape mode
    private(set) var dayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing {
        didSet {
            updateDayViewCellWidth()
        }
    }

    // Width of spacing between day columns in landscape mode
    private(set) var dayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing {
        didSet {
            updateTotalContentHeight()
        }
    }

    // Height of the initial day columns
    fileprivate(set) var initialDayViewCellHeight = LayoutDefaults.dayViewCellHeight {
        didSet {
            updateDayViewCellHeight()
        }
    }

    // Height of the current day columns
    private(set) var dayViewCellHeight = LayoutDefaults.dayViewCellHeight {
        didSet {
            updateTotalContentHeight()
        }
    }

    // Width of an entire day column
    private(set) var dayViewCellWidth: CGFloat {
        didSet {
            updateTotalDayViewCellWidth()
        }
    }

    // Total width of an entire day column including spacing
    private(set) var totalDayViewCellWidth: CGFloat {
        didSet {
            updateMaxOffsetX()
            updateTotalContentWidth()
        }
    }

    // Visible day cells in protrait mode
    fileprivate(set) var portraitVisibleDays = LayoutDefaults.visibleDaysPortrait {
        didSet {
            updateMaximumVisibleDays()
        }
    }
    // Visible day cells in landscape mode
    fileprivate(set) var landscapeVisibleDays = LayoutDefaults.visibleDaysLandscape {
        didSet {
            updateMaximumVisibleDays()
        }
    }

    // Number of days in current year being displayed
    fileprivate(set) var daysInActiveYear = DateSupport.getDaysInYear(DayDate.today.year) {
        didSet {
            updateCollectionViewCellCount()
            updateMaxOffsetX()
        }
    }

    // Collection view cell count buffer, number of cells to de added to the "right" side of the colelction view.
    // This is equal to maximum number of days visisble plus one. This allows for smooth scrolling when crossing the year mark.
    private(set) var collectionViewCellCountBuffer: Int {
        didSet {
            updateCollectionViewCellCount()
        }
    }

    // Number of cells in the collection view
    private(set) var collectionViewCellCount: Int {
        didSet {
            updateTotalContentWidth()
        }
    }

    // Width of spacing between day columns in portrait mode
    fileprivate(set) var portraitDayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing {
        didSet {
            updateOrientationValues()
        }
    }

    // Width of spacing between day columns in landscape mode
    fileprivate(set) var landscapeDayViewHorizontalSpacing = LayoutDefaults.landscapeDayViewHorizontalSpacing {
        didSet {
            updateOrientationValues()
        }
    }

    // Width of spacing between day columns in portrait mode
    fileprivate(set) var portraitDayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing {
        didSet {
            updateOrientationValues()
        }
    }
    // Width of spacing between day columns in landscape mode
    fileprivate(set) var landscapeDayViewVerticalSpacing = LayoutDefaults.landscapeDayViewVerticalSpacing {
        didSet {
            updateOrientationValues()
        }
    }

    // Height of all scrollable content
    private(set) var totalContentHeight: CGFloat {
        didSet {
            updateMaxOffsetY()
        }
    }

    // Height of all scrollable content
    private(set) var totalContentWidth: CGFloat

    // Minimum zoom scale value
    fileprivate(set) var minimumZoomScale = LayoutDefaults.minimumZoom
    // Maximum zoom scale valueapp store
    fileprivate(set) var maximumZoomScale = LayoutDefaults.maximumZoom
    // Min x-axis values that repeating starts at
    private(set) var minOffsetX = CGFloat(0)
    // Max x-axis values that repeating starts at
    private(set) var maxOffsetX: CGFloat
    // Min y-axis values that can be scrolled to
    private(set) var minOffsetY = CGFloat(0)
    // Max y-axis values that can be scrolled to
    private(set) var maxOffsetY: CGFloat {
        didSet {
            if maxOffsetY < minOffsetY {
                maxOffsetY = minOffsetY
            }
        }
    }
    // Velocity multiplier for pagin
    fileprivate(set) var velocityOffsetMultiplier = LayoutDefaults.velocityOffsetMultiplier
    // Height of an all day event
    fileprivate(set) var allDayEventHeight = LayoutDefaults.allDayEventHeight
    // Vertical spacing of an all day event
    fileprivate(set) var allDayEventVerticalSpacing = LayoutDefaults.allDayVerticalSpacing
    // Spread all day events on x axis, if not true than spread will be made on y axis
    fileprivate(set) var allDayEventsSpreadOnX = LayoutDefaults.allDayEventsSpreadOnX

    // MARK: - FONT & COLOUR VARIABLES -

    // Color for day view default color
    fileprivate(set) var defaultDayViewColor = LayoutDefaults.defaultDayViewColor
    // Color for day view weekend color
    fileprivate(set) var weekendDayViewColor = LayoutDefaults.weekendDayViewColor
    // Color for day view passed color
    fileprivate(set) var passedDayViewColor = LayoutDefaults.passedDayViewColor
    // Color for day view passed weekend color
    fileprivate(set) var passedWeekendDayViewColor = LayoutDefaults.passedWeekendDayViewColor
    // Color for today
    fileprivate(set) var todayViewColor = LayoutDefaults.todayViewColor

    // Color for day view hour indicator
    fileprivate(set) var hourIndicatorColor = LayoutDefaults.hourIndicatorColor
    // Thickness for day view hour indicator
    fileprivate(set) var hourIndicatorThickness = LayoutDefaults.hourIndicatorThickness

    // Color for day view main separators
    fileprivate(set) var mainSeparatorColor = LayoutDefaults.backgroundColor
    // Thickness for day view main Separators
    fileprivate(set) var mainSeparatorThickness = LayoutDefaults.mainSeparatorThickness

    // Color for day view dahshed Separators
    fileprivate(set) var dashedSeparatorColor = LayoutDefaults.backgroundColor
    // Thickness for day view dashed Separators
    fileprivate(set) var dashedSeparatorThickness = LayoutDefaults.dashedSeparatorThickness
    // Pattern for day view dashed Separators
    fileprivate(set) var dashedSeparatorPattern = LayoutDefaults.dashedSeparatorPattern

    // Text contained in preview event
    fileprivate(set) var previewEventText = LayoutDefaults.previewEventText
    // Color of the preview event
    fileprivate(set) var previewEventColor = LayoutDefaults.previewEventColor
    // Height of the preview event in hours.
    fileprivate(set) var previewEventHeightInHours = LayoutDefaults.previewEventHeightInHours
    // Number of minutes the preview event will snap to.
    fileprivate(set) var previewEventPrecisionInMinutes = LayoutDefaults.previewEventPrecisionInMinutes
    // Show preview on long press.
    fileprivate(set) var showPreviewOnLongPress = LayoutDefaults.showPreviewOnLongPress

    init() {
        dayViewCellWidth = (activeFrameWidth - dayViewHorizontalSpacing*(visibleDays-1)) / visibleDays
        collectionViewCellCountBuffer = Int(max(portraitVisibleDays, landscapeVisibleDays))+1
        totalDayViewCellWidth = dayViewCellWidth + dayViewHorizontalSpacing
        collectionViewCellCount = daysInActiveYear + collectionViewCellCountBuffer
        totalContentHeight = dayViewVerticalSpacing*2 + dayViewCellHeight
        totalContentWidth = CGFloat(collectionViewCellCount)*totalDayViewCellWidth+dayViewHorizontalSpacing
        maxOffsetX = CGFloat(daysInActiveYear)*totalDayViewCellWidth
        maxOffsetY = totalContentHeight - activeFrameHeight
    }

    // MARK: - UPDATE FUNCTIONS -

    private func updateOrientationValues() {
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

    private func updateDayViewCellWidth() {
        dayViewCellWidth = (activeFrameWidth - dayViewHorizontalSpacing*(visibleDays-1)) / visibleDays
    }

    private func updateDayViewCellHeight() {
        dayViewCellHeight = initialDayViewCellHeight*zoomScale
    }

    private func updateTotalDayViewCellWidth() {
        totalDayViewCellWidth = dayViewCellWidth + dayViewHorizontalSpacing
    }

    private func updateTotalContentHeight() {
        totalContentHeight = dayViewVerticalSpacing*2 + dayViewCellHeight
    }

    private func updateTotalContentWidth() {
        totalContentWidth = CGFloat(collectionViewCellCount)*totalDayViewCellWidth-dayViewHorizontalSpacing
    }

    private func updateMaximumVisibleDays() {
        collectionViewCellCountBuffer = Int(max(portraitVisibleDays, landscapeVisibleDays))
    }

    private func updateCollectionViewCellCount() {
        collectionViewCellCount = collectionViewCellCountBuffer + daysInActiveYear
    }

    private func updateMaxOffsetX() {
        maxOffsetX = CGFloat(daysInActiveYear)*totalDayViewCellWidth
    }

    private func updateMaxOffsetY() {
        maxOffsetY = totalContentHeight - activeFrameHeight
    }
}

extension TextVariables {
    // Font for all event labels
    fileprivate(set) static var eventLabelFont = LayoutDefaults.eventLabelFont
    // Font for all event labels
    fileprivate(set) static var eventLabelInfoFont = LayoutDefaults.eventLabelThinFont
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
    // Showing events' time.
    fileprivate(set) static var eventShowTimeOfEvent = LayoutDefaults.eventShowTimeOfEvent
    // Showing all event's data in one line
    fileprivate(set) static var eventsDataInOneLine = LayoutDefaults.eventsDataInOneLine
}
