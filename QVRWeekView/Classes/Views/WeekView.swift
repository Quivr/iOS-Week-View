//
//  CalendarView.swift

import Foundation
import UIKit

/**
 Class of the main week view. This view can be placed anywhere and will adapt to given size. All behaviours are internal,
 and all customization can be done with public functions. No delegates have been implemented yet. WeekView can be used in both landscape and portrait
 mode.
 */
open class WeekView : UIView {
    
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
    
    // MARK: - VARIABLES -
    
    // WeekView Delegate
    public weak var delegate: WeekViewDelegate?
    // The actual view being displayed, all other views are subview of this mainview
    var mainView: UIView!
    // Array of all daylabels
    private var visibleDayLabels: [Date:UILabel] = [:]
    // Array of labels not being displayed
    private var discardedDayLabels: [UILabel] = []
    // Left side buffer for top bar
    private var topBarLeftBuffer: CGFloat = 0
    // Top side buffer for side bar
    private var sideBarTopBuffer: CGFloat = 0
    // The scale of the latest pinch event
    private var lastTouchScale = CGFloat(0)
    
    // MARK - CONSTRUCTORS/OVERRIDES -
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWeekView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initWeekView()
    }
    
    override open func willMove(toWindow newWindow: UIWindow?) {
        updateTimeDisplayed()
    }
    
    private func initWeekView() {
        // Get the view layout from the nib
        setView()
        // Create pinch recognizer
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomView)))
        // Set clipping to bounds (prevents side bar and other sub view protrusion)
        self.clipsToBounds = true
        // Set dayScrollView parent to self
        self.dayScrollView.parentWeekView = self
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
        
        updateVisibleLabelsAndMainConstraints()
        self.backgroundColor = UIColor.clear
    }

    
    // MARK: - PUBLIC FUNCTIONS -
    
    /**
     Updates the time displayed on the calendar
     */
    public func updateTimeDisplayed() {
        let dayCollectionView = dayScrollView.dayCollectionView!
        for cell in dayCollectionView.visibleCells {
            let indexPath = dayCollectionView.indexPath(for: cell)!
            if let dayViewCell = cell as? DayViewCell {
                let oldDate = dayViewCell.date!
                let possibleLabel = visibleDayLabels[oldDate]
                let newDate = dayScrollView.generateNewDate(forIndexPath: indexPath)
                dayViewCell.setDate(as: newDate)
                if let label = possibleLabel {
                    visibleDayLabels.removeValue(forKey: oldDate)
                    visibleDayLabels[newDate] = label
                }
            }
        }
    }
    
    /**
     Shows the day view cell corresponding to today.
     */
    public func showToday() {
        dayScrollView.showToday()
    }
    
    // MARK: - INTERNAL FUNCTIONS -

    func zoomView(_ sender: UIPinchGestureRecognizer) {
        
        let currentScale = sender.scale
        var touchCenter:CGPoint! = nil
        
        if sender.numberOfTouches >= 2{
            let touch1 = sender.location(ofTouch: 0, in: self)
            let touch2 = sender.location(ofTouch: 1, in: self)
            touchCenter = CGPoint(x: (touch1.x+touch2.x)/2, y: (touch1.y+touch2.y)/2)
        }
        
        dayScrollView.zoomContent(withNewScale: currentScale, newTouchCenter: touchCenter, andState: sender.state)
        updateTopAndSideBarConstraints()
    }
    
    func addLabel(forIndexPath indexPath: IndexPath, withDate date: Date) {
        
        var label:UILabel!
        if discardedDayLabels.count != 0 {
            label = discardedDayLabels[0]
            label.frame = generateDayLabelFrame(forIndex: indexPath)
            discardedDayLabels.remove(at: 0)
        }
        else {
            label = makeDayLabel(withIndexPath: indexPath)
        }
        
        label.text = date.getDayLabelString()
        visibleDayLabels[date] = label
        self.topBarView.addSubview(label)
    }
    
    func discardLabel(withDate date: Date) {
        
        if let label = visibleDayLabels[date]{
            label.removeFromSuperview()
            visibleDayLabels.removeValue(forKey: date)
            discardedDayLabels.append(label)
        }
        
        trashExcessDayLabels()
    }
    
    func updateVisibleLabelsAndMainConstraints() {
        updateTopAndSideBarConstraints()
        
        for cell in dayScrollView.dayCollectionView.visibleCells {
            let indexPath = dayScrollView.dayCollectionView.indexPath(for: cell)!
            if let dayViewCell = cell as? DayViewCell {
                let dateId = dayViewCell.date!
                
                if let label = visibleDayLabels[dateId] {
                    label.frame = generateDayLabelFrame(forIndex: indexPath)
                    label.font = FontVariables.dayLabelFont
                    label.textColor = FontVariables.dayLabelTextColor
                }
            }
        }
        trashExcessDayLabels()
        
    }
    
    func updateTopAndSideBarPositions() {
        sideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.dayCollectionView.contentOffset.x + topBarLeftBuffer
    }
    
    func eventViewWasTapped(_ eventView: EventView) {
        self.delegate?.didTapEvent(self, eventId: 0)
    }
    
    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell) {
        self.delegate?.didLongPressDayViewCell(self, pressedTime: Date())
    }
    
    func loadMoreEvents() {
        self.delegate?.loadNewEvents(self)
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
        
        // Set size contraits of top left buffer view
        
        
        updateTopAndSideBarPositions()
    }
    
    private func trashExcessDayLabels() {
        
        let maxAllowed = Int(LayoutVariables.visibleDays)+1
        
        if discardedDayLabels.count > maxAllowed {
            let overflow = discardedDayLabels.count - maxAllowed
            for i in 0...overflow {
                discardedDayLabels.remove(at: i)
            }
        }
    }
    
    private func makeDayLabel(withIndexPath indexPath: IndexPath) -> UILabel {
    
        // Make as daylabel
        let labelFrame = generateDayLabelFrame(forIndex: indexPath)
        let dayLabel = UILabel(frame: labelFrame)
        dayLabel.font = FontVariables.dayLabelFont
        dayLabel.textColor = FontVariables.dayLabelTextColor
        dayLabel.textAlignment = .center
        return dayLabel
    }
    
    private func generateDayLabelFrame(forIndex indexPath: IndexPath) -> CGRect {
        let row = CGFloat(indexPath.row)
        return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth), y: 0, width: LayoutVariables.dayViewCellWidth, height: topBarHeight)
    }
}

// MARK: - CUSTOMIZATION EXTENSION -

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
        }
    }
    
    /**
     Height of top bar.
     */
    public var topBarHeight: CGFloat {
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
     Background color of the side bar containing hour labels.
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
    public var dayLabelFont: UIFont {
        get {
            return FontVariables.dayLabelFont
        }
        set(font) {
            FontVariables.dayLabelFont = font
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
     Minimum percentage that day label text will be resized to if label is too small.
     (CURRENTLY NOT IMPLEMENTED)
     */
    public var dayLabelMinimumScale: CGFloat {
        get {
            return FontVariables.dayLabelMinimumScale
        }
        set(scale) {
            FontVariables.dayLabelMinimumScale = scale
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
    public var hourLabelMinimumScale: CGFloat {
        get {
            return FontVariables.hourLabelMinimumScale
        }
        set(scale) {
            FontVariables.hourLabelMinimumScale = scale
            updateHourSideBarView()
        }
    }
    
    /**
     Helper function for hour label customization.
     */
    private func updateHourSideBarView() {
        for view in self.sideBarView.subviews{
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
    public var eventLabelMinimumScale: CGFloat {
        get {
            return FontVariables.eventLabelMinimumScale
        }
        set(scale) {
            self.dayScrollView.setEventLabelMinimumScale(to: scale)
        }
    }
    
    /**
     Default color of the day view cells. These are all days that are not weekends.
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
     Color for the overlay displayed ontop of the day view cells. Overlay will indicate which days have passed and how much time of today has passed. Overlay view itself is not transluscent, and requires a background color UIColor with alpha less than 1 for a transluscent effect.
     */
    public var dayViewOverlayColor: UIColor {
        get {
            return LayoutVariables.overlayColor
        }
        set(color) {
            self.dayScrollView.setDayViewOverlayColor(to: color)
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
     Color of the main seperators in the day view cells. Main seperators are full lines and not dashed.
     */
    public var dayViewMainSeperatorColor: UIColor {
        get {
            return LayoutVariables.mainSeperatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewMainSeperatorColor(to: color)
        }
    }
    
    /**
     Thickness of the main seperators in the day view cells. Main seperators are full lines and not dashed.
     */
    public var dayViewMainSeperatorThickness: CGFloat {
        get {
            return LayoutVariables.mainSeperatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewMainSeperatorThickness(to: thickness)
        }
    }
    
    /**
     Color of the dashed/dotted seperators in the day view cells.
     */
    public var dayViewDashedSeperatorColor: UIColor {
        get {
            return LayoutVariables.dashedSeperatorColor
        }
        set(color) {
            self.dayScrollView.setDayViewDashedSeperatorColor(to: color)
        }
    }
    
    /**
     Thickness of the dashed/dotted seperators in the day view cells.
     */
    public var dayViewDashedSeperatorThickness: CGFloat {
        get {
            return LayoutVariables.dashedSeperatorThickness
        }
        set(thickness) {
            self.dayScrollView.setDayViewDashedSeperatorThickness(to: thickness)
        }
    }
    
    /**
     Sets the pattern for the dashed/dotted seperators. Requires an array of NSNumbers.
     Example 1: [10, 5] will provide a pattern of 10 points drawn, 5 points empty, repeated.
     Example 2: [3, 4, 9, 2] will provide a pattern of 4 points drawn, 4 points empty, 9 points drawn, 2 points empty.
     
     See Apple API for additional information on pattern drawing.
     https://developer.apple.com/documentation/quartzcore/cashapelayer/1521921-linedashpattern
     */
    public var dayViewDashedSeperatorPattern: [NSNumber] {
        get {
            return LayoutVariables.dashedSeperatorPattern
        }
        set(pattern) {
            self.dayScrollView.setDayViewDashedSeperatorPattern(to: pattern)
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
     Sensitivity for horizontal scrolling. A higher number will multiply input velocity more and thus result in more cells being skipped when scrolling.
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
    func didLongPressDayViewCell(_ weekView: WeekView, pressedTime: Date)
    
    func didTapEvent(_ weekView: WeekView, eventId: Int)
    
    func loadNewEvents(_ weekView: WeekView)
    
}

// MARK: - WEEKVIEW LAYOUT VARIABLES -

public struct FontVariables {

    // Font for all day labels
    fileprivate(set) static var dayLabelFont = LayoutDefaults.dayLabelFont
    // Text color for all day labels
    fileprivate(set) static var dayLabelTextColor = LayoutDefaults.dayLabelTextColor
    // Minimum scale for all day labels
    fileprivate(set) static var dayLabelMinimumScale = LayoutDefaults.dayLabelMinimumScale
    
    // Font for all hour labels
    fileprivate(set) static var hourLabelFont = LayoutDefaults.hourLabelFont
    // Text color for all hour labels
    fileprivate(set) static var hourLabelTextColor = LayoutDefaults.hourLabelTextColor
    // Minimum scale for all hour labels
    fileprivate(set) static var hourLabelMinimumScale = LayoutDefaults.hourLabelMinimumScale
}
