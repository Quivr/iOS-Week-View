
import UIKit

struct LayoutVariables {
    
    fileprivate(set) static var activeFrameWidth = CGFloat(500) {
        didSet {
            updateDayViewCellWidth()
        }
    }
    
    // Zoom scale of current layout
    fileprivate(set) static var zoomScale = CGFloat(1) {
        didSet {
            updateDayViewCellHeight()
        }
    }
    
    // Number of day columns visible depending on device orientation
    fileprivate(set) static var visibleDays: CGFloat = LayoutDefaults.visibleDaysPortrait {
        didSet {
            updateDayViewCellWidth()
        }
    }
    // Width of spacing between day columns in landscape mode
    fileprivate(set) static var dayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing {
        didSet {
            updateTotalDayViewCellWidth()
        }
    }
    // Width of spacing between day columns in landscape mode
    fileprivate(set) static var dayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing {
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
    fileprivate(set) static var dayViewCellHeight = LayoutDefaults.dayViewCellHeight {
        didSet {
            updateTotalContentHeight()
        }
    }
    
    // Width of an entire day column
    fileprivate(set) static var dayViewCellWidth = CGFloat(0) {
        didSet {
            updateTotalDayViewCellWidth()
        }
    }
    
    // Height of all scrollable content
    fileprivate(set) static var totalContentHeight = dayViewVerticalSpacing + dayViewCellHeight
    
    // Total width of an entire day column including spacing
    fileprivate(set) static var totalDayViewCellWidth = dayViewCellWidth + dayViewHorizontalSpacing
    
    // Visible day cells in protrait mode
    fileprivate(set) static var portraitVisibleDays = LayoutDefaults.visibleDaysPortrait
    // Visible day cells in landscape mode
    fileprivate(set) static var landscapeVisibleDays = LayoutDefaults.visibleDaysLandscape
    
    // Width of spacing between day columns in portrait mode
    fileprivate(set) static var portraitDayViewHorizontalSpacing = LayoutDefaults.portraitDayViewHorizontalSpacing
    // Width of spacing between day columns in landscape mode
    fileprivate(set) static var landscapeDayViewHorizontaSpacing = LayoutDefaults.landscapeDayViewHorizontalSpacing
    
    // Width of spacing between day columns in portrait mode
    fileprivate(set) static var portraitDayViewVerticalSpacing = LayoutDefaults.portraitDayViewVerticalSpacing
    // Width of spacing between day columns in landscape mode
    fileprivate(set) static var landscapeDayViewVerticalSpacing = LayoutDefaults.landscapeDayViewVerticalSpacing
    
    fileprivate(set) static var daysInCollectionView = DateSupport.getDaysInCurrentYear()
    
    // Velocity multiplier for pagin
    fileprivate(set) static var velocityOffsetMultiplier = LayoutDefaults.velocityOffsetMultiplier
    
    
    
    
    // Min x-axis values that repeating starts at
    fileprivate(set) static var minOffsetX:CGFloat = 0
    // Max x-axis values that repeating starts at
    fileprivate(set) static var maxOffsetX:CGFloat = 0
    // Min y-axis values that can be scrolled to
    fileprivate(set) static var minOffsetY:CGFloat = 0
    // Max y-axis values that can be scrolled to
    fileprivate(set) static var maxOffsetY:CGFloat = 0
    
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
        totalContentHeight = dayViewVerticalSpacing + dayViewCellHeight + LayoutDefaults.bottomBufferHeight
    }
}


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
class DayScrollView: UIScrollView, UIScrollViewDelegate {


    // All events
    var allEvents:[EventView] = []
    
    
    // MARK: - PRIVATE VARIABLES -
    
    private(set) var dayCollectionView: DayCollectionView!
    
    // Page offset of today within the current week period
    private var todayPageOffset: Int!
    
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
        setDeviceOrientationValues()
        
        // Calculate min,max and page index/offets.
        calculateIndexAndOffsetConstants()

        // Calculate height and width variables
        widthCalculations()
        heightCalculations()
        
        let dayCollectionView = DayCollectionView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: LayoutVariables.totalContentHeight), collectionViewLayout: DayCollectionViewFlowLayout())
        self.addSubview(dayCollectionView)
        
        self.contentSize = CGSize(width: self.bounds.width, height: dayCollectionView.frame.height)
        
        // Set scroll view properties
        self.isDirectionalLockEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
    }
    
    override func layoutSubviews() {
    
        if self.frame.width != LayoutVariables.activeFrameWidth {
            LayoutVariables.activeFrameWidth = self.frame.width
        }
        
        print(self.contentInset)
        print(self.contentOffset)
        
//        // Recenter logic
//        if currentX > maxOffsetX {
//            scrollContentBackToCenter(withPeriodOffsetChange: +1)
//        }
//        else if currentX < minOffsetX {
//            scrollContentBackToCenter(withPeriodOffsetChange: -1)
//        }
    }
    
    // MARK: - INTERNAL FUNCTIONS -
    
    func renderEvents() {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle side and top bar animations
        if let weekView = self.superview?.superview as? WeekView {
            weekView.setTopAndSideBarPositionConstraints()
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
        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        let pageOffset = round(xOffset / totalDayViewWidth)
        let velocityOffset = round(xVelocity * LayoutVariables.velocityOffsetMultiplier)
        let isNotAlreadyOnPage = (xOffset.truncatingRemainder(dividingBy: totalDayViewWidth) != 0)
        
        if (isNotAlreadyOnPage && velocityOffset != 0){
            let targetXOffset = (pageOffset + velocityOffset)*totalDayViewWidth
            targetContentOffset.pointee.x = targetXOffset.roundedUpToNearestHalf()
        }
    }
    
    func showToday() {
        // TODO: IMPLEMENT WITH COLLECTION VIEW
    }

    func zoomContent(withNewScale newZoomScale: CGFloat, newTouchCenter touchCenter:CGPoint?, andState state:UIGestureRecognizerState) {
        
        // Store previous zoom scale
        let previousZoom = LayoutVariables.zoomScale
        
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
        var currentZoom = previousZoom + zoomChange
        if currentZoom < LayoutDefaults.minimumZoom {
            currentZoom = LayoutDefaults.minimumZoom
        }
        else if currentZoom > LayoutDefaults.maximumZoom {
            currentZoom = LayoutDefaults.maximumZoom
        }
        LayoutVariables.zoomScale = currentZoom
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
        if newYOffset < LayoutVariables.minOffsetY {
            newYOffset = LayoutVariables.minOffsetY
        }
        else if newYOffset > LayoutVariables.maxOffsetY {
            newYOffset = LayoutVariables.maxOffsetY
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
        // Render events
        renderEvents()
    }
    
    func getDate(forIndex index:Int) -> Date {
        // TODO: IMPLEMENT FOR COLLECTION VIEW
        return Date()
    }

    func setInitialVisibleDayViewCellHeight(to height: CGFloat) {
        LayoutVariables.initialDayViewCellHeight = height
        updateVisibleDayViewCellHeight()
    }
    
    /**
     Return true if content view was changed
     */
    func setVisiblePortraitDays(to days:CGFloat) -> Bool{
        
        // Set portrait visisble days variable
        LayoutVariables.portraitVisibleDays = days
        // If device orientation is portrait
        if UIApplication.shared.statusBarOrientation.isPortrait {
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
        LayoutVariables.landscapeVisibleDays = days
        // If device orientation is portrait
        if UIApplication.shared.statusBarOrientation.isLandscape {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    func setVelocityOffsetMultiplier(to multiplier:CGFloat) {
        LayoutVariables.velocityOffsetMultiplier = multiplier
    }
    
    func setPortraitDayViewSideSpacing(to width:CGFloat) -> Bool{
        LayoutVariables.dayViewHorizontalSpacing = width
        if UIApplication.shared.statusBarOrientation.isPortrait {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    func setLandscapeDayViewSideSpacing(to width:CGFloat) -> Bool{
        LayoutVariables.dayViewHorizontalSpacing = width
        if UIApplication.shared.statusBarOrientation.isLandscape {
            updateContentOrientation()
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - HELPER/PRIVATE FUNCTIONS -
    
    
    private func changePeriodOffset(by periodChange:Int){
        // TODO: IMPLEMENT WITH COLLECTION VIEW
    }
    
    private func setDeviceOrientationValues() {

        if UIApplication.shared.statusBarOrientation.isPortrait {
            LayoutVariables.visibleDays = LayoutVariables.portraitVisibleDays
        }
        else if UIApplication.shared.statusBarOrientation.isLandscape {
            LayoutVariables.visibleDays = LayoutVariables.landscapeVisibleDays
        }
    }
    
    private func updateVisibleDayViewCellHeight(updateAllDayViews updateAll:Bool=true) {
        
        // Calculate new height variables
        heightCalculations()
        // Update the day views, content size and offset
        updateDayViewsAndContentSize(updateAllDayViews: updateAll)
    }
    
    /**
     Must be performed after any height or zoom changes.
     */
    private func heightCalculations() {
        

        // Height of the total scroll contents
        // TODO: IMPLEMENT WITH COLLECTION VIEW
    }
    
    /**
     Must be performed after visibleDaycount, orientaton or width changes.
     */
    private func widthCalculations() {
        
        // Get correct width
        var currentWidth = self.frame.width
        let currentHeight = self.frame.height
        // This check is done because frame.width will fetch height instead when first loading in landscape mode.
        if UIApplication.shared.statusBarOrientation.isLandscape && currentHeight > currentWidth{
            currentWidth = currentHeight
        }
        // Width of a day column
        LayoutVariables.dayViewCellWidth = (currentWidth - LayoutVariables.dayViewHorizontalSpacing*(LayoutVariables.visibleDays-1)) / LayoutVariables.visibleDays

        // Width of the total scroll contents
        // TODO: IMPLEMENT WITH COLLECTION VIEW
        
        // Set the x-axis scrolling values that repeating should start at
        // TODO: IMPLEMENT WITH COLLECTION VIEW
//        minOffsetX = CGFloat(minPageIndex) * LayoutVariables.totalDayViewCellWidth
//        maxOffsetX = CGFloat(maxPageIndex) * LayoutVariables.totalDayViewCellWidth
    }
    
    private func calculateIndexAndOffsetConstants() {
    
        // Set the min and max page offset values that repeating should start at.
        todayPageOffset = DateSupport.getWeekDayOfToday()
    }
    
    private func updateDayViewsAndContentSize(updateAllDayViews updateAll:Bool=true) {
        // Update content size
        // TODO: IMPLEMENT WITH COLLECTION VIEW
    }
    
    private func scrollContentBackToCenter(withPeriodOffsetChange periodChange:Int) {

        let newXContentOffset = periodChange == -1 ? LayoutVariables.maxOffsetX : LayoutVariables.minOffsetX
        let scrolledBackOffset = CGPoint(x: newXContentOffset, y: self.contentOffset.y)
        self.contentOffset = scrolledBackOffset
        changePeriodOffset(by: periodChange)
    }
    
    private func scrollToNearestPage() {
        let xOffset = self.contentOffset.x
        let yOffset = self.contentOffset.y
        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        let truncatedToPagingWidth = xOffset.truncatingRemainder(dividingBy: totalDayViewWidth)
        if (truncatedToPagingWidth >= 0.5 && yOffset >= LayoutVariables.minOffsetY && yOffset <= LayoutVariables.maxOffsetY){
            let dividedOffset = xOffset / totalDayViewWidth
            let targetPage = round(dividedOffset)
            let targetXOffset = targetPage*totalDayViewWidth
            self.setContentOffset(CGPoint(x: targetXOffset, y: self.contentOffset.y), animated: true)
        }
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
