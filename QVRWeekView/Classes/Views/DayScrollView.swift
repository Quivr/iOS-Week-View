//
//  DayScrollView.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/9/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import UIKit

/**
 Class of the scroll view contained within the CalendarView.
 
 
 Some variable name clarification. An INDEX refers to the position of an item in relation to all drawn objects. And OFFSET is a number which refers to an objet position in relation to something else such as period count or period size.
 
 All INDICES go from: 0 -> totalDayCount
 OFFSETS can go from: 
        * 0 -> periodSize (pageOffsets)
        * -infinity -> +infinity (periodOffsets)
        * 0 -> totalContentWidth (x-coordinate offsets)
        * 0 -> totalContentHeight
 */
class DayScrollView: UIScrollView, UIScrollViewDelegate {

    // MARK: - INTERNAL VARIABLES -
    
    // UIView containing all scrollView content
    var contentView:UIView!
    // Width of total day view is same as width of a page
    var totalDayViewWidth: CGFloat!
    // Width of day column
    var dayViewWidth: CGFloat!
    // Height of day column
    var dayViewHeight:CGFloat!
    // Top space adjuster for side bar
    var sideBarTopSpacingAdjuster = CGFloat(0)
    // Array of all days
    var allDayViews:[DayView] = []
    // All events
    var allEvents:[EventView] = []
    
    
    // MARK: - PRIVATE VARIABLES -
    
    // Starting y coordinate of day views
    private var dayViewY:CGFloat!
    // Min x-axis values that repeating starts at
    private var minOffsetX:CGFloat!
    // Max x-axis values that repeating starts at
    private var maxOffsetX:CGFloat!
    // Min y-axis values that can be scrolled to
    private var minOffsetY:CGFloat = 0
    // Max y-axis values that can be scrolled to
    private var maxOffsetY:CGFloat!
    // Totale content width
    private var totalContentWidth:CGFloat!
    // Total content height
    private var totalContentHeight:CGFloat!
    
    // Number of day columns visible depending on device orientation
    private var currentVisibleDays: CGFloat = LayoutDefaults.visibleDaysPortrait
    // Width of spacing between day columns in landscape mode
    private var currentDayViewSideSpacing = LayoutDefaults.portraitDayViewSideSpacing
    // Number of periods we have gone into the past or future relative to current week
    private var currentPeriodOffset: Int = 0
    // Offset page within current period
    private var currentPageOffset: Int = 0
    // Smallest index of day column that can be rendered on screen before needing to scroll content back
    private var minPageIndex: Int!
    // Largest index of day column that can be rendered on screen before needing to scroll content back
    private var maxPageIndex: Int!
    // Page offset of today within the current week period
    private var todayPageOffset: Int!
    
    // Previous zoom scale of content
    private var previousZoomTouch:CGPoint?
    // Current zoom scale of content
    private var lastTouchZoomScale = CGFloat(1)
    // Current zoom scale of content
    private var currentZoom = CGFloat(1)
    
    
    // Customizable variables
    
    // Height of an hour cell in a day column
    private var initialDayViewCellHeight = LayoutDefaults.dayViewCellHeight
    // Height of an hour cell in a day column
    private var visibleDayViewCellHeight = LayoutDefaults.dayViewCellHeight
    // Width of spacing between day columns in portrait mode
    private var portraitDayViewSideSpacing = LayoutDefaults.portraitDayViewSideSpacing
    // Width of spacing between day columns in landscape mode
    private var landscapeDayViewSideSpacing = LayoutDefaults.landscapeDayViewSideSpacing
    // Maximum size of day view top spacing
    private var dayViewMaximumTopSpacing = LayoutDefaults.dayViewMaximumTopSpacing
    // Visible days in landscape mode
    private var landscapeVisibleDays = LayoutDefaults.visibleDaysLandscape
    // Visible days in protrait mode
    private var portraitVisibleDays = LayoutDefaults.visibleDaysPortrait
    // Velocity multiplier for pagin
    private var velocityOffsetMultiplier = LayoutDefaults.velocityOffsetMultiplier
    
    
    // MARK: - PRIVATE CONSTANTS -
    
    // Number of day columns in a period
    private let periodLength = LayoutConsts.periodLength
    // Number of periods to be loaded at one time
    private let periodCount = LayoutConsts.numberOfPeriods
    // Total number of day columns loaded at one time
    private let totalDayCount = (LayoutConsts.periodLength*LayoutConsts.numberOfPeriods)

    
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
     Generates and fills the calendar scroll view with day columns.
     */
    private func initDayScrollView() {
        
        // Set visible days variable for device orientation
        setDeviceOrientationValues()
        
        // Calculate min,max and page index/offets.
        calculateIndexAndOffsetConstants()
        
        // Calculate height and width variables
        widthCalculations()
        heightCalculations()
        
        // Generate day views and add them to scroll view and all day view array
        for i in 0...Int(totalDayCount-1) {
            let index = CGFloat(i)
            let currentDay = DayView(frame: generateDayFrame(withIndex: index))
            currentDay.setDayId(as: getDate(forIndex: Int(index)))
            allDayViews.append(currentDay)
            
            self.addSubview(currentDay)
        }
        
        currentPeriodOffset = 0
        currentPageOffset = todayPageOffset
        
        // Update the day views, content size and offset
        updateDayViewsAndContentSize()
        updateOffset()
        // Render events
        renderEvents()
        
        // Set scroll view properties
        self.isDirectionalLockEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
    }
    
    override func layoutSubviews() {
        
        // Keep max y offset value up to date
        maxOffsetY = totalContentHeight - self.frame.height
        
        // Update page offset
        let currentX = self.contentOffset.x
        currentPageOffset = Int(floor((currentX - CGFloat(periodLength)*totalDayViewWidth)/totalDayViewWidth))
        
        // Recenter logic
        if currentX > maxOffsetX {
            scrollContentBackToCenter(withPeriodOffsetChange: +1)
        }
        else if currentX < minOffsetX {
            scrollContentBackToCenter(withPeriodOffsetChange: -1)
        }
    }
    
    // MARK: - INTERNAL FUNCTIONS -
    
    func renderEvents() {
        
        if allEvents.isEmpty {
            let eventTest = EventView(frame: CGRect(x: CGFloat(todayPageOffset+periodLength*(-currentPeriodOffset+1))*totalDayViewWidth, y: dayViewY+8*visibleDayViewCellHeight, width: dayViewWidth, height: 2*visibleDayViewCellHeight))
            allEvents.append(eventTest)
            
            self.addSubview(eventTest)
        }
        else {
            if -1 <= currentPeriodOffset && currentPeriodOffset <= 1 {
                for event in allEvents {
                    event.frame = CGRect(x: CGFloat(todayPageOffset+periodLength*(-currentPeriodOffset+1))*totalDayViewWidth, y: dayViewY+8*visibleDayViewCellHeight, width: dayViewWidth, height: 2*visibleDayViewCellHeight)
                }
            }
            else {
                for event in allEvents {
                    event.removeFromSuperview()
                }
                allEvents = []
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle side and top bar animations
        if let calendarView = self.superview?.superview as? CalendarView {
            calendarView.setTopAndSideBarPositionConstraints()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestPage()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestPage()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let xOffset = scrollView.contentOffset.x
        let xVelocity = velocity.x

        let pageOffset = round(xOffset / totalDayViewWidth)
        let velocityOffset = round(xVelocity * velocityOffsetMultiplier)
        let isNotAlreadyOnPage = (xOffset.truncatingRemainder(dividingBy: totalDayViewWidth) != 0)
        
        if (isNotAlreadyOnPage && velocityOffset != 0){
            let targetXOffset = (pageOffset + velocityOffset)*totalDayViewWidth
            targetContentOffset.pointee.x = targetXOffset.roundedUpToNearestHalf()
        }
    }
    
    func showToday() {
        currentPeriodOffset = 0
        updateDisplayedDates(withPeriodChange: 0)
        // Calculate new target offset to maintain correct page
        currentPageOffset = todayPageOffset
        let targetOffset = (totalDayViewWidth*CGFloat(getCurrentPageIndex())).roundedUpToNearestHalf()
        self.contentOffset = CGPoint(x: targetOffset, y: self.contentOffset.y)
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter:CGPoint?, andState state:UIGestureRecognizerState) {
        
        // Store previous zoom scale
        let previousZoom = currentZoom
        
        // Check if currently in mid zoom
        let midZoom = (state == .began || state == .changed)
        // If zoom just began, set last touch scale
        if state == .began {
            lastTouchZoomScale = newZoomScale
        }
        // Calculate zoom change from lastTouch and new zoom scale.
        let zoomChange = newZoomScale - lastTouchZoomScale
        self.lastTouchZoomScale = newZoomScale
    
        // Set current zoom
        self.currentZoom += zoomChange
        if currentZoom < LayoutDefaults.minimumZoom {
            currentZoom = LayoutDefaults.minimumZoom
        }
        else if currentZoom > LayoutDefaults.maximumZoom {
            currentZoom = LayoutDefaults.maximumZoom
        }
        // Update the height and contents of the visible day views
        updateVisibleDayViewCellHeight(updateAllDayViews: !midZoom)
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
            if midZoom, let touch = touchCenter{
                newYOffset += (previousTouchCenter.y-touch.y)
                self.previousZoomTouch = touchCenter
            }
            else {
                self.previousZoomTouch = nil
            }
        }
        else if midZoom {
            self.previousZoomTouch = touchCenter
        }
        
        // Check that new y offset is not out of bounds
        if newYOffset < minOffsetY {
            newYOffset = minOffsetY
        }
        else if newYOffset > maxOffsetY {
            newYOffset = maxOffsetY
        }
        
        // Pass new y offset to scroll view
        self.contentOffset.y = newYOffset
        // Render events
        renderEvents()
        
        if state == .cancelled || state == .ended || state == .failed {
            scrollToNearestPage()
        }
    }
    
    func updateContentOrientation() {
        
        // Set the correct value for current visible days
        setDeviceOrientationValues()
        // Calculate new width variables
        widthCalculations()
        // Update the day views and content size
        updateDayViewsAndContentSize()
        // Update offset
        updateOffset()
        // Render events
        renderEvents()
    }
    
    func updateDisplayedDates(withPeriodChange periodChange:Int) {
        
        if let calendarView = self.superview?.superview as? CalendarView {
            if periodChange == -1 {
                for i in stride(from: periodLength*periodCount-1, to: periodLength-1, by: -1) {
                    allDayViews[i].setDayId(as: allDayViews[i-periodLength].date)
                    calendarView.allDayLabels[i].text = calendarView.allDayLabels[i-periodLength].text
                }
                for i in 0...periodLength-1 {
                    let newDate = getDate(forIndex: i)
                    allDayViews[i].setDayId(as: newDate)
                    calendarView.allDayLabels[i].text = newDate.getDayLabelString()
                }
            }
            else if periodChange == 1 {
                for i in 0...periodLength*(periodCount-1)-1 {
                    allDayViews[i].setDayId(as: allDayViews[i+periodLength].date)
                    calendarView.allDayLabels[i].text = calendarView.allDayLabels[i+periodLength].text
                }
                for i in periodLength*(periodCount-1)...periodLength*periodCount-1 {
                    let newDate = getDate(forIndex: i)
                    allDayViews[i].setDayId(as: newDate)
                    calendarView.allDayLabels[i].text = newDate.getDayLabelString()
                }
            }
            else {
                var i = 0
                for dayView in allDayViews {
                    let newDate = getDate(forIndex: i)
                    dayView.setDayId(as: newDate)
                    calendarView.allDayLabels[i].text = newDate.getDayLabelString()
                    i += 1
                }
            }
        }
        // Render events after updating displayed dates
        renderEvents()
    }
    
    func getDate(forIndex index:Int) -> Date {
        return DateSupport.getDayDate(forDaysInFuture: (index-periodLength*(-currentPeriodOffset+1))-todayPageOffset)
    }

    func setInitialVisibleDayViewCellHeight(to height: CGFloat) {
        initialDayViewCellHeight = height
        updateVisibleDayViewCellHeight()
    }
    
    /**
     Return true if content view was changed
     */
    func setVisiblePortraitDays(to days:CGFloat) -> Bool{
        
        // Set portrait visisble days variable
        self.portraitVisibleDays = days
        let ori = UIDevice.current.orientation
        // If device orientation is portrait
        if ori == .portrait {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    /**
     Return true if content view was changed
     */
    func setVisibleLandscapeDays(to days:CGFloat) -> Bool{
        
        // Set portrait visisble days variable
        self.landscapeVisibleDays = days
        let ori = UIDevice.current.orientation
        // If device orientation is portrait
        if ori == .landscapeRight || ori == .landscapeLeft {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    func setVelocityOffsetMultiplier(to multiplier:CGFloat) {
        self.velocityOffsetMultiplier = multiplier
    }
    
    func setPortraitDayViewSideSpacing(to width:CGFloat) -> Bool{
        self.portraitDayViewSideSpacing = width
        if UIDevice.current.orientation.isPortrait {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    func setLandscapeDayViewSideSpacing(to width:CGFloat) -> Bool{
        self.landscapeDayViewSideSpacing = width
        if UIDevice.current.orientation.isLandscape {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - HELPER/PRIVATE FUNCTIONS -
    
    
    private func changePeriodOffset(by periodChange:Int){
        
        // Set new period offset
        currentPeriodOffset += periodChange
        // Update the UI to display the new dates
        updateDisplayedDates(withPeriodChange: periodChange)
    }
    
    private func setDeviceOrientationValues() {

        if UIDevice.current.orientation.isPortrait {
            currentVisibleDays = portraitVisibleDays
            currentDayViewSideSpacing = portraitDayViewSideSpacing
        }
        else if UIDevice.current.orientation.isLandscape {
            currentVisibleDays = landscapeVisibleDays
            currentDayViewSideSpacing = landscapeDayViewSideSpacing
        }
    }
    
    private func updateVisibleDayViewCellHeight(updateAllDayViews updateAll:Bool=true) {
        
        // Set current day cell view height
        visibleDayViewCellHeight = initialDayViewCellHeight*currentZoom
        // Calculate new height variables
        heightCalculations()
        // Update the day views, content size and offset
        updateDayViewsAndContentSize(updateAllDayViews: updateAll)
    }
    
    /**
     Must be performed after any height or zoom changes.
     */
    private func heightCalculations() {
        
        // Height of day view column
        dayViewHeight = visibleDayViewCellHeight*24
        // Height of hour side bar
        let hourSideBarHeight = dayViewHeight - 1
        // Height of hour label
        let hourLabelHeight = hourSideBarHeight/24
        // Top spacing of day columns, or starting y offset of day columns
        dayViewY = hourLabelHeight/2
        // Check if top view spacing is too large
        if dayViewY > dayViewMaximumTopSpacing {
            // Correct side bar top spacing and day view y
            sideBarTopSpacingAdjuster = dayViewMaximumTopSpacing - dayViewY
            dayViewY = dayViewMaximumTopSpacing
        }
        // Height of the total scroll contents
        totalContentHeight = dayViewY + dayViewHeight + LayoutConsts.bottomBufferHeight
    }
    
    /**
     Must be performed after visibleDaycount, orientaton or width changes.
     */
    private func widthCalculations() {
        
        // Get correct width
        var currentWidth = self.frame.width
        let currentHeight = self.frame.height
        // This check is done because frame.width will fetch height instead when first loading in landscape mode.
        if UIDevice.current.orientation.isLandscape && currentHeight > currentWidth{
            currentWidth = currentHeight
        }
        // Width of a day column
        dayViewWidth = (currentWidth - currentDayViewSideSpacing*(currentVisibleDays-1)) / currentVisibleDays
        // Total width of day column including the spacing
        totalDayViewWidth = dayViewWidth+currentDayViewSideSpacing
        // Width of the total scroll contents
        totalContentWidth = CGFloat(totalDayCount)*totalDayViewWidth - currentDayViewSideSpacing
        
        // Set the x-axis scrolling values that repeating should start at
        minOffsetX = CGFloat(minPageIndex) * totalDayViewWidth
        maxOffsetX = CGFloat(maxPageIndex) * totalDayViewWidth
    }
    
    private func calculateIndexAndOffsetConstants() {
    
        // Set the min and max page offset values that repeating should start at.
        minPageIndex = periodLength
        maxPageIndex = totalDayCount - periodLength
        todayPageOffset = DateSupport.getWeekDayOfToday()
    }
    
    private func updateDayViewsAndContentSize(updateAllDayViews updateAll:Bool=true) {
        
        let currentPageIndex = getCurrentPageIndex()
        // Update content size
        self.contentSize = CGSize(width: totalContentWidth, height: totalContentHeight)
        // Generate new day view frames
        var index = CGFloat(0)
        for day in allDayViews {
            if updateAll {
                day.frame = generateDayFrame(withIndex: index)
                day.updateBottomOverlayConstraint()
            }
            else {
                if Int(index) >= currentPageIndex && Int(index) < currentPageIndex+Int(currentVisibleDays)+1 {
                    day.frame = generateDayFrame(withIndex: index)
                    day.updateBottomOverlayConstraint()
                }
            }
            index += 1
        }
    }
    
    private func updateOffset() {
        
        let currentPageIndex = getCurrentPageIndex()
        // Calculate new target offset to maintain correct page
        let targetOffset = (totalDayViewWidth*CGFloat(currentPageIndex)).roundedUpToNearestHalf()
        self.contentOffset = CGPoint(x: targetOffset, y: self.contentOffset.y)
    }
    
    private func scrollContentBackToCenter(withPeriodOffsetChange periodChange:Int) {

        let newXContentOffset = periodChange == -1 ? maxOffsetX! : minOffsetX!
        let scrolledBackOffset = CGPoint(x: newXContentOffset, y: self.contentOffset.y)
        self.contentOffset = scrolledBackOffset
        changePeriodOffset(by: periodChange)
    }
    
    private func scrollToNearestPage() {
        let xOffset = self.contentOffset.x
        let yOffset = self.contentOffset.y
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)
        if (truncatedToPagingWidth >= 0.5 && yOffset >= minOffsetY && yOffset <= maxOffsetY){
            let dividedOffset = xOffset / totalDayViewWidth
            let targetPage = round(dividedOffset)
            let targetXOffset = targetPage*totalDayViewWidth
            self.setContentOffset(CGPoint(x: targetXOffset, y: self.contentOffset.y), animated: true)
        }
    }
    
    private func generateDayFrame(withIndex index:CGFloat) -> CGRect{
        return CGRect(x: index*(totalDayViewWidth), y: dayViewY, width: dayViewWidth, height: dayViewHeight)
    }
    
    private func getCurrentPageIndex() -> Int {
        return periodLength + currentPageOffset
    }
    
    private func forceResetScrollViewContent() {
        // Remove all day views and labels
        for view in self.subviews {
            if let day = view as? DayView{
                day.removeFromSuperview()
            }
        }
        // Reinitialise the scroll content
        initDayScrollView()
    }
}
