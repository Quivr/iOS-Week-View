import Foundation
import UIKit

// MARK: - DAY SCROLL VIEW -
/**

 Class of the scroll view contained within the WeekView.
 
 Some variable name clarification. An INDEX refers to the position of an item in relation to all drawn objects. And OFFSET is a number which refers to an objet position in relation to something else such as period count or period size.
 
 All INDICES go from: 0 -> totalDayCount
 OFFSETS can go from: 
        * 0 -> periodSize (pageOffsets)
        * -infinity -> +infinity (periodOffsets)
        * 0 -> totalContentWidth (x-coordinate offsets)
        * 0 -> totalContentHeight
 */
class DayScrollView: UIScrollView, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {


    // All events
    var allEvents:[Date:[[String:String]]] = [:]
    
    // MARK: - PRIVATE VARIABLES -
    
    private(set) var dayCollectionView: DayCollectionView!
    
    // Offset of current year
    private var yearOffset: Int = 0
    // Day of today in year
    private var dayOfYearToday: Int = Date().getDayOfYear()
    // Bool stores if the collection view just reset
    private var didJustResetView:Bool = false
    // Previous zoom scale of content
    private var previousZoomTouch:CGPoint?
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
        dayCollectionView = DayCollectionView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: LayoutVariables.totalContentHeight), collectionViewLayout: DayCollectionViewFlowLayout())
        dayCollectionView.contentOffset = CGPoint(x: LayoutVariables.totalDayViewCellWidth*CGFloat(dayOfYearToday), y: 0)
        dayCollectionView.delegate = self
        dayCollectionView.dataSource = self
        self.addSubview(dayCollectionView)
        
        self.contentSize = CGSize(width: self.bounds.width, height: dayCollectionView.frame.height)
        
        // Set scroll view properties
        self.isDirectionalLockEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
        
        // Make test event
        // TODO: REPLACE WITH REAL EVENTS
        let testEvents:[[String:String]] = [
            [EventKeys.id: "01", EventKeys.title: "Event number two", EventKeys.time: "8", EventKeys.duration: "2"],
            [EventKeys.id: "02", EventKeys.title: "Event number three", EventKeys.time: "13", EventKeys.duration: "3"],
            [EventKeys.id: "03", EventKeys.title: "Event number four", EventKeys.time: "20", EventKeys.duration: "1"],
            [EventKeys.id: "04", EventKeys.title: "Event number one", EventKeys.time: "00", EventKeys.duration: "4"],
        ]
        allEvents[Date()] = testEvents
    }
    
    override func layoutSubviews() {
    
        if self.frame.width != LayoutVariables.activeFrameWidth || self.frame.height != LayoutVariables.activeFrameHeight{
            updateLayout()
        }
    }
    
    // MARK: - DELEGATE & DATA SOURCE FUNCTIONS -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Handle side bar animations
        if let weekView = self.superview?.superview as? WeekView {
            weekView.updateTopAndSideBarPositions()
        }
        
        if let collectionView = scrollView as? DayCollectionView {
            if collectionView.contentOffset.x < LayoutVariables.minOffsetX {
                resetView(ofScrollView: collectionView, withYearOffsetChange: -1)
            }
            else if collectionView.contentOffset.x > LayoutVariables.maxOffsetX {
                resetView(ofScrollView: collectionView, withYearOffsetChange: 1)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let collectionView = scrollView as? DayCollectionView, !decelerate {
            scrollToNearestPage(withScrollView: collectionView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? DayCollectionView {
            scrollToNearestPage(withScrollView: collectionView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LayoutVariables.collectionViewCellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dayViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellKeys.dayViewCell, for: indexPath) as! DayViewCell
        dayViewCell.clearValues()
        let dateForCell = getDate(forIndexPath: indexPath)
        dayViewCell.setDate(as: dateForCell)
        
        for events in allEvents {
            if events.key.isSameDayAs(dateForCell) {
                dayViewCell.setEventViews(events.value)
            }
        }
        
        return dayViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let weekView = self.superview?.superview as? WeekView, let dayViewCell = cell as? DayViewCell {
            weekView.addLabel(forIndexPath: indexPath, withDate: dayViewCell.date!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let weekView = self.superview?.superview as? WeekView, let dayViewCell = cell as? DayViewCell {
            weekView.discardLabel(withDate: dayViewCell.date!)
        }
    }
    
    // MARK: - INTERNAL FUNCTIONS -
    
    func showToday() {
        yearOffset = 0
        dayCollectionView.contentOffset = CGPoint(x: CGFloat(dayOfYearToday)*LayoutVariables.totalDayViewCellWidth, y: 0)
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter:CGPoint?, andState state:UIGestureRecognizerState) {
        
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
            if let touch = touchCenter{
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
            scrollToNearestPage(withScrollView: dayCollectionView)
        }
    }
    
    func updateLayout() {
        
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
        // Update content size and maintain offset position
        dayCollectionView.contentSize = CGSize(width: LayoutVariables.totalContentWidth, height: LayoutVariables.totalContentHeight)

        if oldWidth != 0 && oldWidth != dayCollectionView.contentSize.width{
            let newXOffset = CGFloat(CGFloat(oldIndexPath.row)*LayoutVariables.totalDayViewCellWidth).roundedUpToNearestHalf()
            dayCollectionView.contentOffset = CGPoint(x: newXOffset, y: 0)
        }
        else {
            dayCollectionView.contentOffset = CGPoint(x: oldXOffset, y: 0)
        }
        
        if let weekView = self.superview?.superview as? WeekView {
            weekView.updateVisibleLabelsAndMainConstraints()
        }
    }
    
    func getDate(forIndexPath indexPath:IndexPath) -> Date{
        let dayCount = indexPath.row - dayOfYearToday + LayoutVariables.daysInActiveYear*yearOffset
        return DateSupport.getDayDate(forDaysInFuture: dayCount)
    }
    
    // MARK: - HELPER/PRIVATE FUNCTIONS -
    
    
    private func resetView(ofScrollView scrollView:UIScrollView, withYearOffsetChange change:Int){
        didJustResetView = true
        yearOffset += change
        LayoutVariables.daysInActiveYear = Date().getDaysInYear(withYearOffset: yearOffset)
        if change < 0 {
            scrollView.contentOffset.x = LayoutVariables.maxOffsetX
        }
        else if change > 0 {
            scrollView.contentOffset.x = LayoutVariables.minOffsetX
        }
    }
    
    private func scrollToNearestPage(withScrollView scrollView:UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let yOffset = scrollView.contentOffset.y
        
        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)
        
        if (truncatedToPagingWidth >= 0.5 && yOffset >= LayoutVariables.minOffsetY && yOffset <= LayoutVariables.maxOffsetY){
            
            let targetXOffset = round(xOffset / totalDayViewWidth)*totalDayViewWidth
            scrollView.setContentOffset(CGPoint(x: targetXOffset, y: scrollView.contentOffset.y), animated: true)
        }
        didJustResetView = false
    }
    
    private func updateDayViewCellSizeAndSpacing() {
        if let flowLayout = dayCollectionView.collectionViewLayout as? DayCollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.dayViewCellHeight)
            flowLayout.minimumLineSpacing = LayoutVariables.dayViewHorizontalSpacing
        }
    }
    
}

// MARK: - CUSTOMIZATION EXTENSION -

extension DayScrollView {
    
    /**
     Sets the height of the day view cells for zoom scale 1.
     */
    func setInitialVisibleDayViewCellHeight(to height: CGFloat) {
        LayoutVariables.initialDayViewCellHeight = height
        updateLayout()
    }
    
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
     Sets the spacing in between day view cells for portrait mode.
     */
    func setPortraitDayViewSideSpacing(to width: CGFloat) -> Bool {
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
    func setLandscapeDayViewSideSpacing(to width: CGFloat) -> Bool {
        LayoutVariables.landscapeDayViewHorizontalSpacing = width
        if LayoutVariables.orientation.isLandscape {
            updateLayout()
            return true
        }
        return false
    }
    
    /**
     Sets the height of the top bar.
     */
    func setTopBarHeight(to height: CGFloat) {
        LayoutVariables.topBarHeight = height
    }
    
    /**
     Sets the color of the top bar.
     */
    func setTopBarColor(to color: UIColor) {
        LayoutVariables.topBarColor = color
    }
    
    /**
     Sets the width of the side bar.
     */
    func setSideBarWidth(to width: CGFloat) {
        LayoutVariables.sideBarWidth = width
    }
    
    /**
     Sets the color of the side bar.
     */
    func setSideBarColor(to color: UIColor) {
        LayoutVariables.sideBarColor = color
    }
    
    /**
     Sets the font for day labels.
     */
    func setDayLabelFont(to font: UIFont) {
        LayoutVariables.dayLabelFont = font
    }
    
    /**
     Sets the text color for day labels.
     */
    func setDayLabelTextColor(to color: UIColor) {
        LayoutVariables.dayLabelTextColor = color
    }
    
    /**
     Sets the font for hour labels.
     */
    func setHourLabelFont(to font: UIFont) {
        LayoutVariables.hourLabelFont = font
    }
    
    /**
     Sets the text color for hour labels.
     */
    func setHourLabelTextColor(to color: UIColor) {
        LayoutVariables.hourLabelTextColor = color
    }
    
    /**
     Sets the font for event labels.
     */
    func setEventLabelFont(to font: UIFont) {
        LayoutVariables.eventLabelFont = font
        layoutIfNeeded()
    }
    
    /**
     Sets the text color for event labels.
     */
    func setEventLabelTextColor(to color: UIColor) {
        LayoutVariables.eventLabelTextColor = color
        layoutIfNeeded()
    }
    
    /**
     Sets the minimum scale for day labels.
     */
    func setEventLabelMinimumScale(to scale: CGFloat) {
        LayoutVariables.eventLabelMinimumScale = scale
        layoutIfNeeded()
    }
    
    /**
     Sets the color of default day view color.
     */
    func setDefaultDayViewColor(to color: UIColor) {
        LayoutVariables.defaultDayViewColor = color
        layoutIfNeeded()
    }
    
    /**
     Sets the color of weekend day view color.
     */
    func setWeekendDayViewColor(to color: UIColor) {
        LayoutVariables.weekendDayViewColor = color
        layoutIfNeeded()
    }
    
    /**
     Sets the color of day view overlays.
     */
    func setDayViewOverlayColor(to color: UIColor) {
        LayoutVariables.overlayColor = color
        layoutIfNeeded()
    }
    
    /**
     Sets the color of day view hour indicators.
     */
    func setDayViewHourIndicatorColor(to color: UIColor) {
        LayoutVariables.hourIndicatorColor = color
        layoutIfNeeded()
    }
    
    /**
     Sets the color of day view seperators.
     */
    func setDayViewMainSeperatorColor(to color: UIColor) {
        LayoutVariables.mainSeperatorColor = color
        layoutIfNeeded()
    }
    
    /**
     Sets the sensitivity of horizontal scrolling.
     */
    func setVelocityOffsetMultiplier(to multiplier: CGFloat) {
        LayoutVariables.velocityOffsetMultiplier = multiplier
    }
    
    
}

// MARK: - LAYOUT VARIABLES -

struct LayoutVariables {
    
    // MARK: - SCROLLVIEW LAYOUT & SPACING VARIABLES -
    
    fileprivate(set) static var orientation:UIInterfaceOrientation = .portrait {
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
        didSet{
            updateMaximumVisibleDays()
        }
    }
    // Visible day cells in landscape mode
    fileprivate(set) static var landscapeVisibleDays = LayoutDefaults.visibleDaysLandscape {
        didSet{
            updateMaximumVisibleDays()
        }
    }
    
    // Number of days in current year being displayed
    fileprivate(set) static var daysInActiveYear = Date().getDaysInYear(withYearOffset: 0) {
        didSet {
            updateCollectionViewCellCount()
            updateMaxOffsetX()
        }
    }
    
    // Maximum number of days visisble
    private(set) static var maximumVisibleDays = Int(max(portraitVisibleDays, landscapeVisibleDays)) {
        didSet {
            updateCollectionViewCellCount()
        }
    }
    
    // Number of cells in the collection view
    private(set) static var collectionViewCellCount = daysInActiveYear + maximumVisibleDays {
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
    private(set) static var maxOffsetY = totalContentHeight - activeFrameHeight
    // Velocity multiplier for pagin
    fileprivate(set) static var velocityOffsetMultiplier = LayoutDefaults.velocityOffsetMultiplier
    
    // MARK: - WEEKVIEW LAYOUT & SPACING VARIABLES -
    
    // Height of the top bar
    fileprivate(set) static var topBarHeight = LayoutDefaults.topBarHeight
    // Color of the top bar
    fileprivate(set) static var topBarColor = LayoutDefaults.topBarColor
    // Width of the side bar
    fileprivate(set) static var sideBarWidth = LayoutDefaults.sideBarWidth
    // Color of the top bar
    fileprivate(set) static var sideBarColor = LayoutDefaults.backgroundColor
    
    
    // MARK: - FONT & COLOUR VARIABLES -
    
    // Font for all day labels
    fileprivate(set) static var dayLabelFont = LayoutDefaults.dayLabelFont
    // Text color for all day labels
    fileprivate(set) static var dayLabelTextColor = LayoutDefaults.dayLabelTextColor
    
    // Font for all hour labels
    fileprivate(set) static var hourLabelFont = LayoutDefaults.hourLabelFont
    // Text color for all hour labels
    fileprivate(set) static var hourLabelTextColor = LayoutDefaults.hourLabelTextColor
    
    // Font for all event labels
    fileprivate(set) static var eventLabelFont = LayoutDefaults.eventLabelFont
    // Text color for all event labels
    fileprivate(set) static var eventLabelTextColor = LayoutDefaults.eventLabelTextColor
    // Minimum scaling for all event labels
    fileprivate(set) static var eventLabelMinimumScale = LayoutDefaults.eventLabelMinimumScale
    
    // Color for day view default color
    fileprivate(set) static var defaultDayViewColor = LayoutDefaults.defaultDayViewColor
    // Color for day view weekend color
    fileprivate(set) static var weekendDayViewColor = LayoutDefaults.weekendDayViewColor
    
    // Color for day view overlays
    fileprivate(set) static var overlayColor = LayoutDefaults.overlayColor
    
    // Color for day view hour indicator
    fileprivate(set) static var hourIndicatorColor = LayoutDefaults.hourIndicatorColor
    // Thickness for day view hour indicator
    fileprivate(set) static var hourIndiactorThickness = LayoutDefaults.hourIndicatorThickness
    
    // Color for day view main seperators
    fileprivate(set) static var mainSeperatorColor = LayoutDefaults.backgroundColor
    // Thickness for day view main seperators
    fileprivate(set) static var mainSeperatorThickness = LayoutDefaults.mainSeperatorThickness
    
    // Pattern for day view dashed seperators
    fileprivate(set) static var dashedSeperatorPattern = LayoutDefaults.dashedSeperatorPattern
    // Color for day view dahshed seperators
    fileprivate(set) static var dashedSeperatorColor = LayoutDefaults.backgroundColor
    // Thickness for day view dashed seperators
    fileprivate(set) static var dashedSeperatorThickness = LayoutDefaults.dashedSeperatorThickness
    
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
        maximumVisibleDays = Int(max(portraitVisibleDays, landscapeVisibleDays))
    }
    
    private static func updateCollectionViewCellCount() {
        collectionViewCellCount = maximumVisibleDays + daysInActiveYear
    }
    
    private static func updateMaxOffsetX() {
        maxOffsetX = CGFloat(daysInActiveYear)*totalDayViewCellWidth
    }
    
    private static func updateMaxOffsetY() {
        maxOffsetY = totalContentHeight - activeFrameHeight
    }
}
