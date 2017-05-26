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
                dayViewCell.setDate(as: dayScrollView.getDate(forIndexPath: indexPath))
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
                let date = dayViewCell.date!
                if let label = visibleDayLabels[date] {
                    label.frame = generateDayLabelFrame(forIndex: indexPath)
                    label.font = LayoutVariables.dayLabelFont
                    label.textColor = LayoutVariables.dayLabelTextColor
                }
            }
        }
    }
    
    func updateTopAndSideBarPositions() {
        sideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.dayCollectionView.contentOffset.x + topBarLeftBuffer
    }
    
    func updateColors() {
        self.backgroundColor = UIColor.clear
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
        return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth), y: 0, width: LayoutVariables.dayViewCellWidth, height: topBarView.frame.height)
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
     Sets background color of main scrollview.
     - parameters:
       - color: New background color.
     */
    public func setBackgroundColor(to color: UIColor) {
        mainView.backgroundColor = color
    }
    
    /**
     Sets height of top bar.
     - parameters:
       - height: New height for top bar.
     */
    public func setTopBarHeight(to height: CGFloat) {
        dayScrollView.setTopBarHeight(to: height)
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets background color of top bar.
     - parameters:
       - color: New color for top bar.
     */
    public func setTopBarColor(to color: UIColor) {
        topBarView.backgroundColor = color
        topLeftBufferView.backgroundColor = color
    }
    
    /**
     Sets font used for day labels.
     - parameters:
       - font: New font for all day labels.
     */
    public func setDayLabelFont(to font: UIFont) {
        dayScrollView.setDayLabelFont(to: font)
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayLabelTextColor(to color: UIColor) {
        dayScrollView.setDayLabelTextColor(to: color)
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setSideBarColor(to color: UIColor) {
        sideBarView.backgroundColor = color
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setSideBarWidth(to width: CGFloat) {
        dayScrollView.setSideBarWidth(to: width)
        updateVisibleLabelsAndMainConstraints()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setHourLabelFont(to font: UIFont) {
        dayScrollView.setHourLabelFont(to: font)
        updateHourSideBarView()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setHourLabelTextColor(to color: UIColor) {
        dayScrollView.setHourLabelTextColor(to: color)
        updateHourSideBarView()
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewCellColor(to color: UIColor) {
        // TODO: IMPLEMENT WITH COLLECTION VIEW
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewCellSeperatorColor(to color: UIColor) {
        // TODO: IMPLEMENT WITH COLLECTION VIEW
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
    public func setDayViewSideSpacingPortrait(to width: CGFloat) {
        if dayScrollView.setPortraitDayViewSideSpacing(to: width) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewSideSpacingLandscape(to width: CGFloat) {
        if dayScrollView.setLandscapeDayViewSideSpacing(to: width) {
            updateVisibleLabelsAndMainConstraints()
        }
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewOverlayColor(to color: UIColor) {

    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewHourIndicatorColor(to color: UIColor) {
        
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewHourIndicatorThickness(to color: UIColor) {
        
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewSeperatorColor(to color: UIColor) {
        
    }

    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewSeperatorLineThickness(to thickness: CGFloat) {
        
    }
    
    /**
     Sets
     - parameters:
     -
     */
    public func setDayViewDashedLineSeperatorPattern(to pattern: [CGFloat]) {
        
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
