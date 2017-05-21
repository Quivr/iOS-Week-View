//
//  CalendarView.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/9/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation
import UIKit

/**
 Class of the main calendar view. This view can be placed anywhere and will adapt to given size. All behaviours are internal, 
 and all customization can be done with public functions. No delegates required.
 
 CalendarView can be used in either landscape or portrait mode but for it to work CalendarView.frame is required to be given
 updated width and height whenever device orientation changes. This works and has only been tested with constraints but as 
 long as frame is updated before new device orientation notifications are sent it should work fine.
 */
public class CalendarView : UIView {
    
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
    var allDayLabels:[UILabel] = []
    // The actual view being displayed, all other views are subview of this mainview
    private var mainView:UIView!
    // Left side buffer for top bar
    var topBarLeftBuffer:CGFloat!
    // Top side buffer for side bar
    var sideBarTopBuffer:CGFloat!
    // The scale of the latest pinch event
    private var lastTouchScale = CGFloat(0)
    
    // Customization variables
    
    // Height of top bar
    private var topBarHeight = LayoutDefaults.topBarHeight
    // Width of side bar
    private var sideBarWidth = LayoutDefaults.sideBarWidth
    // Height of an hour cell in a day column
    private var dayViewCellHeight = LayoutDefaults.dayViewCellHeight
    
    // MARK: - CONSTANTS -
    
    private let totalDayCount = (LayoutConsts.numberOfPeriods*LayoutConsts.periodLength)
    
    // MARK - CONSTRUCTORS/OVERRIDES -
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCalendarView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initCalendarView()
    }
    
    private func initCalendarView() {
        // Get the view layout from the nib
        setView()
        // Update top bar and side constraints
        updateTopAndSideBarConstraints()
        // Draw day labels
        createDayLabels()
        // Create pinch recognizer
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomView)))
        // Create device orientation listeners
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        // Set clipping to bounds (prevents side bar and other sub view protrusion)
        self.clipsToBounds = true
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        updateTimeDisplayed()
    }
    
    // MARK: - PUBLIC FUNCTIONS -
    
    public func setDirectionalLock(to value:Bool){
        dayScrollView.isDirectionalLockEnabled = value
    }
    
    public func setVisibleDaysPortrait(numberOfDays days: Int){
        if dayScrollView.setVisiblePortraitDays(to: CGFloat(days)) {
            updateLabelsAndConstraints()
        }
    }
    
    public func setVisibleDaysLandscape(numberOfDays days: Int){
        if dayScrollView.setVisibleLandscapeDays(to: CGFloat(days)) {
            updateLabelsAndConstraints()
        }
    }
    
    public func setBackgroundColor(to color: UIColor) {
        mainView.backgroundColor = color
    }
    
    public func setTopBarHeight(to height: CGFloat) {
        topBarHeight = height
        topBarHeightConstraint.constant = height
        topLeftBufferHeightConstraint.constant = height
    }
    
    public func setTopBarColor(to color: UIColor) {
        topBarView.backgroundColor = color
        topLeftBufferView.backgroundColor = color
    }
    
    public func setDayLabelFont(to font: UIFont) {
        for label in allDayLabels {
            label.font = font
        }
    }
    
    public func setDayLabelTextColor(to color: UIColor) {
        for label in allDayLabels {
            label.textColor = color
        }
    }
    
    public func setSideBarColor(to color: UIColor) {
        sideBarView.backgroundColor = color
    }
    
    public func setSideBarWidth(to width: CGFloat){
        sideBarWidthConstraint.constant = width
        topLeftBufferWidthConstraint.constant = width
        sideBarWidth = width
    }
    
    public func setHourLabelFont(to font: UIFont) {
        for sub in sideBarView.subviews {
            if let hourSideBar = sub as? HourSideBarView {
                for hourLabel in hourSideBar.hourLabels {
                    hourLabel.font = font
                }
            }
        }
    }
    
    public func setHourLabelTextColor(to color: UIColor) {
        for sub in sideBarView.subviews {
            if let hourSideBar = sub as? HourSideBarView {
                for hourLabel in hourSideBar.hourLabels {
                    hourLabel.textColor = color
                }
            }
        }
    }
    
    public func setDayViewCellColor(to color: UIColor) {
        for dayView in dayScrollView.allDayViews {
            dayView.view!.backgroundColor = color
        }
    }
    
    public func setDayViewCellSeperatorColor(to color: UIColor) {
        for dayView in dayScrollView.allDayViews {
            for seperator in dayView.seperators {
                seperator.backgroundColor = color
            }
        }
    }
    
    /**
     For zoom scale 1.0
     */
    public func setDayViewCellHeight(to height: CGFloat) {
        dayScrollView.setInitialVisibleDayViewCellHeight(to: height)
    }
    
    public func setDayViewSideSpacingPortrait(to width: CGFloat) {
        if dayScrollView.setPortraitDayViewSideSpacing(to: width) {
            updateLabelsAndConstraints()
        }
    }
    
    public func setDayViewSideSpacingLandscape(to width: CGFloat) {
        if dayScrollView.setLandscapeDayViewSideSpacing(to: width) {
            updateLabelsAndConstraints()
        }
    }
    
    public func setVelocityOffsetMultiplier(to multiplier:CGFloat) {
        dayScrollView.setVelocityOffsetMultiplier(to: multiplier)
    }
    
    /**
     Updates the time displayed on the calendar
     */
    public func updateTimeDisplayed() {
        if dayScrollView != nil {
            dayScrollView.updateDisplayedDates(withPeriodChange: 0)
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
    
    func deviceOrientationChanged() {
        
        dayScrollView.updateContentOrientation()
        updateLabelsAndConstraints()
    }
    
    func setTopAndSideBarPositionConstraints() {
        sideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.contentOffset.x + topBarLeftBuffer
    }
    
    // MARK: - PRIVATE/HELPER FUNCTIONS -
    
    private func updateLabelsAndConstraints() {
        updateTopAndSideBarConstraints()
        
        var index = CGFloat(0)
        for label in allDayLabels {
            label.frame = generateDayLabelFrame(forIndex: index)
            index += 1
        }
    }
    
    private func updateTopAndSideBarConstraints() {

        // Height of total side bar
        let sideBarHeight = dayScrollView.dayViewHeight + dayViewCellHeight - 1
        
        // Set position and size constraints for side bar
        hourSideBarBottomConstraint.constant = dayViewCellHeight
        sideBarHeightConstraint.constant = sideBarHeight
        sideBarTopBuffer = dayScrollView.sideBarTopSpacingAdjuster
        
        // Set correct size and constraints of top bar
        topBarWidthConstraint.constant = dayScrollView.contentSize.width
        topBarLeftBuffer = sideBarWidth
        
        setTopAndSideBarPositionConstraints()
    }

    
    private func createDayLabels() {
        
        // Add days and day labels to scroll view
        for i in 0...Int(totalDayCount-1) {
            
            let index = CGFloat(i)
            
            // Make and add day label to top bar
            let labelFrame = generateDayLabelFrame(forIndex: index)
            let dayLabel = UILabel(frame: labelFrame)
            dayLabel.font = UIFont.boldSystemFont(ofSize: LayoutDefaults.dayLabelFontSize)
            dayLabel.text = getDayLabelText(withIndex: i)
            dayLabel.textAlignment = .center
            allDayLabels.append(dayLabel)
            topBarView.addSubview(dayLabel)
            
        }
    }
    
    private func generateDayLabelFrame(forIndex index:CGFloat) -> CGRect{
        return CGRect(x: index*(dayScrollView.totalDayViewWidth), y: 0, width: dayScrollView.dayViewWidth, height: topBarHeight)
    }
    
    private func getDayLabelText(withIndex index:Int) -> String{
        return dayScrollView.getDate(forIndex: index).getDayLabelString()
    }
    
    private func setView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: NibNames.calendarView, bundle: bundle)
        self.mainView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        if mainView != nil {
            self.mainView!.frame = self.bounds
            self.mainView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.mainView!)
        }
        self.backgroundColor = UIColor.clear
    }
}
