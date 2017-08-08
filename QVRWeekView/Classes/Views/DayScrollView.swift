import Foundation
import UIKit

// MARK: - DAY SCROLL VIEW -
/**

 Class of the scroll view contained within the WeekView.
 
 */
class DayScrollView: UIScrollView, UIScrollViewDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, DayViewCellDelegate, FrameCalculatorDelegate {

    // MARK: - INSTANCE VARIABLES -

    // Collection view
    private(set) var dayCollectionView: DayCollectionView!
    // All eventData objects
    private(set) var allEventsData: [DayDate: [Int: EventData]] = [:]
    // All event framesAll
    private(set) var allEventFrames: [DayDate: [Int: CGRect]] = [:]
    // All fullday events
    private var allDayEvents: [DayDate: [EventData]] = [:]
    // All active dayViewCells
    private var dayViewCells: [Int: DayViewCell] = [:]
    // All frame calculators
    private var frameCalculators: [DayDate: FrameCalculator] = [:]
    // Active year on view
    private var yearActive: Int = DayDate.today.year {
        didSet {
            LayoutVariables.daysInActiveYear = DateSupport.getDaysInYear(yearActive)
        }
    }
    // Current active day
    private(set) var activeDay: DayDate = DayDate.today
    // Year todauy
    private var yearToday: Int = DayDate.today.year
    // Current period
    private var currentPeriod: Period = Period(ofDate: DayDate.today)
    // Bool stores if the collection view just reset
    private var didJustResetView: Bool = false
    // Bool stores if event thread is running
    private var eptRunning: Bool = false
    // Bool stores if event thread should stop
    private var eptSafeContinue: Bool = false
    // Stores most recently assigned event data
    private var eptTempData: [EventData]?
    // Previous zoom scale of content
    private var previousZoomTouch: CGPoint?
    // Current zoom scale of content
    private var lastTouchZoomScale = CGFloat(1)

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
        dayCollectionView.contentOffset = CGPoint(x: LayoutVariables.totalDayViewCellWidth*CGFloat(DayDate.today.day), y: 0)
        dayCollectionView.contentSize = CGSize(width: LayoutVariables.totalContentWidth, height: LayoutVariables.totalContentHeight)
        dayCollectionView.delegate = self
        dayCollectionView.dataSource = self
        self.addSubview(dayCollectionView)

        // Set content size for vertical scrolling
        self.contentSize = CGSize(width: self.bounds.width, height: dayCollectionView.frame.height)

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

        if self.frame.width != LayoutVariables.activeFrameWidth || self.frame.height != LayoutVariables.activeFrameHeight {
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
            if collectionView.contentOffset.x < LayoutVariables.minOffsetX {
                resetView(withYearOffsetChange: -1)
            }
            else if collectionView.contentOffset.x > LayoutVariables.maxOffsetX {
                resetView(withYearOffsetChange: 1)
            }

            let cvLeft = CGPoint(x: collectionView.contentOffset.x, y: collectionView.center.y + collectionView.contentOffset.y)

            if  let path = collectionView.indexPathForItem(at: cvLeft),
                let dayViewCell = collectionView.cellForItem(at: path) as? DayViewCell {

                activeDay = dayViewCell.date
                if activeDay > currentPeriod.endDate {
                    // Remove redundant events
                    for day in currentPeriod.previousPeriod.allDaysInPeriod() {
                        allEventsData.removeValue(forKey: day)
                    }
                    // Set current period to next period
                    currentPeriod = currentPeriod.nextPeriod
                    // Load new events for new period
                    requestEvents()
                }
                else if activeDay < currentPeriod.startDate {
                    // Remove redundant events
                    for day in currentPeriod.nextPeriod.allDaysInPeriod() {
                        allEventsData.removeValue(forKey: day)
                    }
                    // Set current period to previous period
                    currentPeriod = currentPeriod.previousPeriod
                    // Load new events for new period
                    requestEvents()
                }
            }
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
        return LayoutVariables.collectionViewCellCount
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
            weekView.addLabel(forIndexPath: indexPath, withDate: dayViewCell.date)
            if let allDayEvents = allDayEvents[dayViewCell.date] {
                weekView.addAllDayEvents(allDayEvents, forIndexPath: indexPath, withDate: dayViewCell.date)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let weekView = self.superview?.superview as? WeekView, let dayViewCell = cell as? DayViewCell {
            weekView.discardLabel(withDate: dayViewCell.date)
            weekView.discardAllDayEvents(forDate: dayViewCell.date)
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
        }
    }

    // solution == nil => do not render events. solution.isEmpty => render empty
    func passSolution(fromCalculator calculator: FrameCalculator, solution: [Int : CGRect]?) {
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

    func goToAndShow(dayDate: DayDate) {
        yearActive = dayDate.year
        dayCollectionView.setContentOffset(CGPoint(x: CGFloat(dayDate.dayInYear)*LayoutVariables.totalDayViewCellWidth,
                                                   y: 0),
                                           animated: false)
        currentPeriod = Period(ofDate: dayDate)
        activeDay = dayDate
        requestEvents()
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter: CGPoint?, andState state: UIGestureRecognizerState) {

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
        if currentZoom < LayoutDefaults.minimumZoom {
            currentZoom = LayoutDefaults.minimumZoom
        }
        else if currentZoom > LayoutDefaults.maximumZoom {
            currentZoom = LayoutDefaults.maximumZoom
        }
        LayoutVariables.zoomScale = currentZoom
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
            scrollToNearestCell()
        }
    }

    func getDayDate(forIndexPath indexPath: IndexPath) -> DayDate {

        var dayCount = (indexPath.row - DayDate.today.day)
        let yearOffset = yearActive - yearToday
        if yearOffset != 0 {
            let delta = (yearOffset / abs(yearOffset))
            var yearCursor = yearActive
            while yearCursor != yearToday {
                let days = DateSupport.getDaysInYear(yearCursor)
                dayCount += delta*days
                yearCursor -= delta
            }
        }
        let date = DateSupport.getDate(forDaysInFuture: dayCount)
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
            var newEventsData: [DayDate: [Int: EventData]] = [:]
            // New all day events
            var newAllDayEvents: [DayDate: [EventData]] = [:]
            // Stores the days which will be changed
            var changedDayDates = Set<DayDate>()

            guard self.eptSafeContinue else {
                self.safe_call_overwriteAllEvents()
                return
            }

            // Process raw event data and sort it into the allEventsData dictionary. Also check to see which
            // days have had any changes done to them to queue them up for processing.
            for eventData in eventsData {
                guard self.eptSafeContinue else {
                    self.safe_call_overwriteAllEvents()
                    return
                }
                let start = eventData.startDate
                let end = eventData.endDate

                if eventData.allDay {
                    let dayDate = DayDate(date: start)
                    newAllDayEvents.addEvent(eventData, onDay: dayDate)
                }
                else {
                    if start.isSameDayAs(end) {
                        let dayDate = DayDate(date: start)
                        if !changedDayDates.contains(dayDate) &&
                            Util.isEvent(eventData, fromDay: dayDate, notInOrHasChanged: self.allEventsData) {
                            changedDayDates.insert(dayDate)
                        }
                        newEventsData.addEvent(eventData, onDay: dayDate)
                    }
                    else if !start.isSameDayAs(end) && end.isMidnight() {
                        let dayDate = DayDate(date: start)
                        let newData = eventData.remakeEventData(withStart: start, andEnd: end.addingTimeInterval(TimeInterval(exactly: -1)!))
                        if !changedDayDates.contains(dayDate) &&
                            Util.isEvent(eventData, fromDay: dayDate, notInOrHasChanged: self.allEventsData) {
                            changedDayDates.insert(dayDate)
                        }
                        newEventsData.addEvent(newData, onDay: dayDate)
                    }
                    else if !end.isMidnight() {
                        let allDays = DateSupport.getAllDates(between: start, and: end)
                        let splitEvent = eventData.split(across: allDays)
                        for (date, event) in splitEvent {
                            let dayDate = DayDate(date: date)
                            if !changedDayDates.contains(dayDate) &&
                                Util.isEvent(event, fromDay: dayDate, notInOrHasChanged: self.allEventsData) {
                                changedDayDates.insert(dayDate)
                            }
                            newEventsData.addEvent(event, onDay: dayDate)
                        }
                    }
                }
            }

            guard self.eptSafeContinue else {
                self.safe_call_overwriteAllEvents()
                return
            }

            // Get sequence of active days
            let activeDates = DateSupport.getAllDayDates(between: self.currentPeriod.previousPeriod.startDate,
                                                         and: self.currentPeriod.nextPeriod.endDate)
            // Iterate through all old days that have not been checked yet to look for inactive days
            for (dayDate, oldEvents) in self.allEventsData where !changedDayDates.contains(dayDate) && activeDates.contains(dayDate) {
                for (_, oldEvent) in oldEvents where Util.isEvent(oldEvent, fromDay: dayDate, notInOrHasChanged: newEventsData) {
                    changedDayDates.insert(dayDate)
                    break
                }
            }

            guard self.eptSafeContinue else {
                self.safe_call_overwriteAllEvents()
                return
            }

            // Iterate through all old all day events that have not been checked yet to look for inactive days
            for (dayDate, _) in self.allDayEvents where activeDates.contains(dayDate) && newAllDayEvents[dayDate] == nil {
                newAllDayEvents[dayDate] = []
                break
            }

            guard self.eptSafeContinue else {
                self.safe_call_overwriteAllEvents()
                return
            }

            let sortedChangedDays = changedDayDates.sorted { (smaller, larger) -> Bool in
                let diff1 = abs(smaller.day - self.activeDay.day)
                let diff2 = abs(larger.day - self.activeDay.day)
                return diff1 == diff2 ? smaller > larger : diff1 < diff2
            }

            // Safe exit
            DispatchQueue.main.sync {
                self.eptRunning = false
                self.eptSafeContinue = false
                self.allEventsData = newEventsData
                self.allDayEvents = newAllDayEvents
                for cell in self.dayCollectionView.visibleCells {
                    if let dayViewCell = cell as? DayViewCell,
                       let weekView = self.superview?.superview as? WeekView,
                       let events = self.allDayEvents[dayViewCell.date] {
                        if events.isEmpty {
                            weekView.discardAllDayEvents(forDate: dayViewCell.date)
                        }
                        else {
                            weekView.addAllDayEvents(events, forIndexPath: self.dayCollectionView.indexPath(for: cell)!, withDate: dayViewCell.date)
                        }
                    }
                }
                for dayDate in sortedChangedDays {
                    self.processEventsData(forDayDate: dayDate)
                }
            }
        }
    }

    private func safe_call_overwriteAllEvents() {
        DispatchQueue.main.sync {
            eptRunning = false
            overwriteAllEvents(withData: eptTempData)
        }
    }

    func requestEvents() {
        if let weekView = self.superview?.superview as? WeekView {
            let startDate = currentPeriod.previousPeriod.startDate
            let endDate = currentPeriod.nextPeriod.endDate
            for (date, calc) in frameCalculators where date < startDate || date > endDate {
                calc.cancelCalculation()
            }
            weekView.requestEvents(between: startDate, and: endDate)
        }
    }

    // MARK: - HELPER/PRIVATE FUNCTIONS -

    fileprivate func updateLayout() {

        // Get old offset ratio before resizing cells
        let oldXOffset = dayCollectionView.contentOffset.x
        let oldIndexPath = IndexPath(row: Int(round((oldXOffset/LayoutVariables.totalDayViewCellWidth))), section: 0)
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
            let newXOffset = CGFloat(CGFloat(oldIndexPath.row)*LayoutVariables.totalDayViewCellWidth).roundUpAdditionalHalf()
            dayCollectionView.contentOffset = CGPoint(x: newXOffset, y: 0)
        }
        else {
            dayCollectionView.contentOffset = CGPoint(x: oldXOffset, y: 0)
        }

        // Update content size
        dayCollectionView.contentSize = CGSize(width: LayoutVariables.totalContentWidth, height: LayoutVariables.totalContentHeight)

        if let weekView = self.superview?.superview as? WeekView {
            weekView.updateVisibleLabelsAndMainConstraints()
        }
    }

    private func resetView(withYearOffsetChange change: Int) {
        didJustResetView = true
        yearActive += change

        if change < 0 {
            dayCollectionView.contentOffset.x = (LayoutVariables.maxOffsetX).roundDownSubtractedHalf()
        }
        else if change > 0 {
            dayCollectionView.contentOffset.x = (LayoutVariables.minOffsetX).roundUpAdditionalHalf()
        }
    }

    private func scrollToNearestCell() {
        let xOffset = dayCollectionView.contentOffset.x
        let yOffset = dayCollectionView.contentOffset.y

        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)

        if truncatedToPagingWidth >= 0.5 && yOffset >= LayoutVariables.minOffsetY && yOffset <= LayoutVariables.maxOffsetY {
            let targetXOffset = (round(xOffset / totalDayViewWidth)*totalDayViewWidth).roundUpAdditionalHalf()
            dayCollectionView.setContentOffset(CGPoint(x: targetXOffset, y: dayCollectionView.contentOffset.y), animated: true)
        }
        didJustResetView = false
    }

    private func updateDayViewCellSizeAndSpacing() {
        if let flowLayout = dayCollectionView.collectionViewLayout as? DayCollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.dayViewCellHeight)
            flowLayout.minimumLineSpacing = LayoutVariables.dayViewHorizontalSpacing
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
     Sets the font for event labels.
     */
    func setEventLabelFont(to font: UIFont) {
        FontVariables.eventLabelFont = font
        updateLayout()
    }

    /**
     Sets the text color for event labels.
     */
    func setEventLabelTextColor(to color: UIColor) {
        FontVariables.eventLabelTextColor = color
        updateLayout()
    }

    /**
     Sets the minimum scale for day labels.
     */
    func setEventLabelMinimumScale(to scale: CGFloat) {
        FontVariables.eventLabelMinimumScale = scale
        updateLayout()
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
     Sets the sensitivity of horizontal scrolling.
     */
    func setVelocityOffsetMultiplier(to multiplier: CGFloat) {
        LayoutVariables.velocityOffsetMultiplier = multiplier
    }
}

// MARK: - DAYSCROLLVIEW DELEGATE -

protocol DayScrollViewDelegate: class {

    func dayCellWasLongPressed(sender: DayScrollView, dayCell: DayViewCell)

    func eventWasTapped(sender: DayScrollView, event: EventData)

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

    // MARK: - FONT & COLOUR VARIABLES -

    // Color for day view default color
    fileprivate(set) static var defaultDayViewColor = LayoutDefaults.defaultDayViewColor
    // Color for day view weekend color
    fileprivate(set) static var weekendDayViewColor = LayoutDefaults.weekendDayViewColor
    // Color for day view passed color
    fileprivate(set) static var passedDayViewColor = LayoutDefaults.passedDayViewColor
    // Color for day view passed weekend color
    fileprivate(set) static var passedWeekendDayViewColor = LayoutDefaults.passedWeekendDayViewColor

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

    // Height of an all day event
    fileprivate(set) static var allDayEventHeight = LayoutDefaults.allDayEventHeight
    // Vertical spacing of an all day event
    fileprivate(set) static var allDayEventVerticalSpacing = LayoutDefaults.allDayVerticalSpacing

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

extension FontVariables {

    // Font for all event labels
    fileprivate(set) static var eventLabelFont = LayoutDefaults.eventLabelFont
    // Text color for all event labels
    fileprivate(set) static var eventLabelTextColor = LayoutDefaults.eventLabelTextColor
    // Minimum scaling for all event labels
    fileprivate(set) static var eventLabelMinimumScale = LayoutDefaults.eventLabelMinimumScale
}
