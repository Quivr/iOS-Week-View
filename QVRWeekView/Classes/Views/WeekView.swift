//
//  CalendarView.swift

import Foundation
import UIKit

/**
 Class of the main week view. This view can be placed anywhere and will adapt to given size. All behaviours are internal,
 and all customization can be done with public functions. No delegates required.
 
 WeekView can be used in either landscape or portrait mode but for it to work WeekView is required to be given
 updated width and height whenever device orientation changes. This works and has only been tested with constraints but as 
 long as frame is updated before new device orientation notifications are sent it should work fine.
 */
public class WeekView : UIView {
    
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
    
    // MARK: - PRIVATE VARIABLES -
    
    // Array of all daylabels
    private var visibleDayLabels:[Date:UILabel] = [:]
    // Array of labels not being displayed
    private var discardedDayLabels:[UILabel] = []
    // Left side buffer for top bar
    private var topBarLeftBuffer:CGFloat = 0
    // Top side buffer for side bar
    private var sideBarTopBuffer:CGFloat = 0
    
    // The actual view being displayed, all other views are subview of this mainview
    var mainView:UIView!
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
    
    private func initWeekView() {
        // Get the view layout from the nib
        setView()
        // Create pinch recognizer
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomView)))
        // Set clipping to bounds (prevents side bar and other sub view protrusion)
        self.clipsToBounds = true
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        updateTimeDisplayed()
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
                let newDate = dayScrollView.getDate(forIndexPath: indexPath)
                dayViewCell.setDate(as: newDate)
                if let label = possibleLabel {
                    visibleDayLabels.removeValue(forKey: oldDate)
                    visibleDayLabels[newDate] = label
                }
            }
        }
    }
    
    public func showToday() {
        dayScrollView.showToday()
    }
    
    // MARK: - INTERNAL FUNCTIONS -

    func zoomView(_ sender:UIPinchGestureRecognizer) {
        
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
    
    func addLabel(forIndexPath indexPath:IndexPath, withDate date:Date) {
        
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
    
    func discardLabel(withDate date:Date) {
        
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
                    label.font = LayoutVariables.dayLabelFont
                    label.textColor = LayoutVariables.dayLabelTextColor
                }
            }
        }
        trashExcessDayLabels()
        
    }
    
    func updateTopAndSideBarPositions() {
        sideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.dayCollectionView.contentOffset.x + topBarLeftBuffer
    }
    
    func updateColors() {
        self.backgroundColor = UIColor.clear
        self.mainView.backgroundColor = LayoutVariables.backgroundColor
        self.sideBarView.backgroundColor = LayoutVariables.sideBarColor
        self.topLeftBufferView.backgroundColor = LayoutVariables.topBarColor
        self.topBarView.backgroundColor = LayoutVariables.topBarColor
    }
    
    // MARK: - PRIVATE/HELPER FUNCTIONS -
    
    private func updateTopAndSideBarConstraints() {
        
        // Height of total side bar
        let dayViewCellHeight = LayoutVariables.dayViewCellHeight
        let dayViewCellHourHeight = dayViewCellHeight/DateSupport.hoursInDay
        let sideBarHeight = dayViewCellHeight + dayViewCellHourHeight
        
        // Set position and size constraints for side bar and hour view
        hourSideBarBottomConstraint.constant = dayViewCellHourHeight
        sideBarWidthConstraint.constant = LayoutVariables.sideBarWidth
        sideBarHeightConstraint.constant = sideBarHeight
        sideBarTopBuffer = LayoutVariables.dayViewVerticalSpacing - dayViewCellHourHeight/2
        
        // Set correct size and constraints of top bar view
        topBarHeightConstraint.constant = LayoutVariables.topBarHeight
        topBarWidthConstraint.constant = dayScrollView.dayCollectionView.contentSize.width
        topBarLeftBuffer = sideBarView.frame.width
        
        // Set size contraits of top left buffer view
        topLeftBufferWidthConstraint.constant = LayoutVariables.sideBarWidth
        topLeftBufferHeightConstraint.constant = LayoutVariables.topBarHeight
        
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
    
    private func makeDayLabel(withIndexPath indexPath:IndexPath) -> UILabel {
    
        // Make as daylabel
        let labelFrame = generateDayLabelFrame(forIndex: indexPath)
        let dayLabel = UILabel(frame: labelFrame)
        dayLabel.font = LayoutVariables.dayLabelFont
        dayLabel.textColor = LayoutVariables.dayLabelTextColor
        dayLabel.textAlignment = .center
        return dayLabel
    }
    
    private func generateDayLabelFrame(forIndex indexPath:IndexPath) -> CGRect {
        let row = CGFloat(indexPath.row)
        return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth), y: 0, width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.topBarHeight)
    }
    
    private func setView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: NibNames.weekView, bundle: bundle)
        self.mainView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        if mainView != nil {
            self.mainView!.frame = self.bounds
            self.mainView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.mainView!)
        }
        
        updateVisibleLabelsAndMainConstraints()
        updateColors()
    }
}

// MARK: - CUSTOMIZATION EXTENSION -

public extension WeekView {

    // MARK: - WEEKVIEW CUSTOMIZATION -
    
    /**
     Sets background color of main scrollview.
     - parameters:
       - color: New background color.
     */
    public func setBackgroundColor(to color: UIColor) {
        LayoutVariables.backgroundColor = color
        updateColors()
    }
    
    /**
     Sets height of top bar.
     - parameters:
       - height: New height for top bar.
     */
    public func setTopBarHeight(to height: CGFloat) {
        LayoutVariables.topBarHeight = height
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets background color of top bar.
     - parameters:
       - color: New color for top bar.
     */
    public func setTopBarColor(to color: UIColor) {
        LayoutVariables.topBarColor = color
        updateColors()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setSideBarColor(to color: UIColor) {
        LayoutVariables.sideBarColor = color
        updateColors()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setSideBarWidth(to width: CGFloat) {
        LayoutVariables.sideBarWidth = width
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets font used for day labels.
     - parameters:
     - font: New font for all day labels.
     */
    public func setDayLabelFont(to font: UIFont) {
        LayoutVariables.dayLabelFont = font
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayLabelTextColor(to color: UIColor) {
        LayoutVariables.dayLabelTextColor = color
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayLabelMinimumScale(to scale: CGFloat) {
        LayoutVariables.dayLabelMinimumScale = scale
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setHourLabelFont(to font: UIFont) {
        LayoutVariables.hourLabelFont = font
        updateHourSideBarView()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setHourLabelTextColor(to color: UIColor) {
        LayoutVariables.hourLabelTextColor = color
        updateHourSideBarView()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setHourLabelMinimumScale(to scale: CGFloat) {
        LayoutVariables.hourLabelMinimumScale = scale
        updateVisibleLabelsAndMainConstraints()
    }
    
    // MARK: - DAYSCROLLVIEW CUSTOMIZATION -
    
    /**
     Sets number of visible days when in portait mode.
     - parameters:
     - days: New number of days.
     */
    public func setVisibleDaysPortrait(numberOfDays days: Int){
        if dayScrollView.setVisiblePortraitDays(to: CGFloat(days)) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets number of visible days when in landscape mode.
     - parameters:
     - days: New number of days.
     */
    public func setVisibleDaysLandscape(numberOfDays days: Int){
        if dayScrollView.setVisibleLandscapeDays(to: CGFloat(days)) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setEventLabelFont(to font: UIFont) {
        dayScrollView.setEventLabelFont(to: font)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setEventLabelTextColor(to color: UIColor) {
        dayScrollView.setEventLabelTextColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setEventLabelMinimumScale(to scale: CGFloat) {
        dayScrollView.setEventLabelMinimumScale(to: scale)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDefaultDayViewColor(to color: UIColor) {
        dayScrollView.setDefaultDayViewColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setWeekendDayViewColor(to color: UIColor) {
        dayScrollView.setWeekendDayViewColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewOverlayColor(to color: UIColor) {
        dayScrollView.setDayViewOverlayColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewHourIndicatorColor(to color: UIColor) {
        dayScrollView.setDayViewHourIndicatorColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewHourIndicatorThickness(to thickness: CGFloat) {
        dayScrollView.setDayViewHourIndicatorThickness(to: thickness)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewMainSeperatorColor(to color: UIColor) {
        dayScrollView.setDayViewMainSeperatorColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewMainSeperatorThickness(to thickness: CGFloat) {
        dayScrollView.setDayViewMainSeperatorThickness(to: thickness)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewDashedSeperatorColor(to color: UIColor) {
        dayScrollView.setDayViewDashedSeperatorColor(to: color)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewDashedSeperatorThickness(to thickness: CGFloat) {
        dayScrollView.setDayViewDashedSeperatorThickness(to: thickness)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewDashedSeperatorPattern(to pattern: [NSNumber]) {
        dayScrollView.setDayViewDashedSeperatorPattern(to: pattern)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewCellHeight(to height: CGFloat) {
        dayScrollView.setInitialVisibleDayViewCellHeight(to: height)
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setPortraitDayViewSideSpacing(to width: CGFloat) {
        if dayScrollView.setPortraitDayViewHorizontalSpacing(to: width) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setLandscapeDayViewSideSpacing(to width: CGFloat) {
        if dayScrollView.setLandscapeDayViewHorizontalSpacing(to: width) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setPortraitDayViewVerticalSpacing(to width: CGFloat) {
        if dayScrollView.setPortraitDayViewVerticalSpacing(to: width) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setLandscapeDayViewVerticalSpacing(to width: CGFloat) {
        if dayScrollView.setLandscapeDayViewVerticalSpacing(to: width) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setVelocityOffsetMultiplier(to multiplier:CGFloat) {
        dayScrollView.setVelocityOffsetMultiplier(to: multiplier)
    }
    
    
    
    private func updateHourSideBarView() {
        for view in sideBarView.subviews{
            if let hourSideBarView = view as? HourSideBarView {
                hourSideBarView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - WEEKVIEW LAYOUT VARIABLES -

extension LayoutVariables {
    
    // Main background color
    fileprivate(set) static var backgroundColor = LayoutDefaults.backgroundColor
    // Height of the top bar
    fileprivate(set) static var topBarHeight = LayoutDefaults.topBarHeight
    // Color of the top bar
    fileprivate(set) static var topBarColor = LayoutDefaults.topBarColor
    // Width of the side bar
    fileprivate(set) static var sideBarWidth = LayoutDefaults.sideBarWidth
    // Color of the top bar
    fileprivate(set) static var sideBarColor = LayoutDefaults.backgroundColor
    
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
