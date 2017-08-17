//
//  CalendarView.swift

import Foundation
import UIKit

/**
 Class of the main week view. This view can be placed anywhere and will adapt to given size. All behaviours are internal,
 and all customization can be done with public functions. No delegates have been implemented yet.
 WeekView can be used in both landscape and portrait mode.
 */
open class WeekView: UIView {

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

    // MARK: - PUBLIC PROPERTIES -

    // WeekView Delegate
    public weak var delegate: WeekViewDelegate?

    public var currentDay: Date {
        return dayScrollView.activeDay.dateObj
    }

    // MARK: - PRIVATE VARIABLES -

    // The actual view being displayed, all other views are subview of this mainview
    private(set) var mainView: UIView!
    // Array of visible daylabels
    private var visibleDayLabels: [DayDate: UILabel] = [:]
    // Array of visible allDayEvents
    private var visibleAllDayEvents: [DayDate: [EventData: CAShapeLayer]] = [:]
    // Array of labels not being displayed
    private var discardedDayLabels: [UILabel] = []
    // Left side buffer for top bar
    private var topBarLeftBuffer: CGFloat = 0
    // Top side buffer for side bar
    private var sideBarTopBuffer: CGFloat = 0
    // The scale of the latest pinch event
    private var lastTouchScale = CGFloat(0)

    // MARK: - CONSTRUCTORS/OVERRIDES -

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWeekView()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initWeekView()
    }

    open override func didMoveToWindow() {
        updateTimeDisplayed()
        dayScrollView.requestEvents()
    }

    private func initWeekView() {
        // Get the view layout from the nib
        setView()
        // Create pinch recognizer
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomView(_:))))
        // Create tap recognizer for top bar
        self.topBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopBar(_:))))
        // Set clipping to bounds (prevents side bar, top bar and other sub view protrusion)
        self.clipsToBounds = true
        self.topBarView.clipsToBounds = true
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
        self.backgroundColor = UIColor.clear
        updateVisibleLabelsAndMainConstraints()
    }

    // MARK: - PUBLIC FUNCTIONS -

    /**
     Updates the time displayed on the calendar
     */
    public func updateTimeDisplayed() {
        let dayCollectionView = dayScrollView.dayCollectionView!
        for cell in dayCollectionView.visibleCells {
            if let dayViewCell = cell as? DayViewCell {
                dayViewCell.updateTimeView()
            }
        }
    }

    /**
     Shows the day view cell corresponding to asked day.
     */
    public func showDay(withDate date: Date) {
        dayScrollView.goToAndShow(dayDate: DayDate(date: date))
    }

    /**
     Shows the day view cell corresponding to today.
     */
    public func showToday() {
        dayScrollView.goToAndShow(dayDate: DayDate(date: Date()), showNow: true)
    }

    /**
     Overwrittes all events with new data.
     */
    public func loadEvents(withData eventsData: [EventData]?) {
        guard eventsData != nil else {
            return
        }
        dayScrollView.overwriteAllEvents(withData: eventsData)
    }

    // MARK: - INTERNAL FUNCTIONS -

    func zoomView(_ sender: UIPinchGestureRecognizer) {

        let currentScale = sender.scale
        var touchCenter: CGPoint! = nil

        if sender.numberOfTouches >= 2 {
            let touch1 = sender.location(ofTouch: 0, in: self)
            let touch2 = sender.location(ofTouch: 1, in: self)
            touchCenter = CGPoint(x: (touch1.x+touch2.x)/2, y: (touch1.y+touch2.y)/2)
        }

        dayScrollView.zoomContent(withNewScale: currentScale, newTouchCenter: touchCenter, andState: sender.state)
        updateTopAndSideBarConstraints()
    }

    func addLabel(forIndexPath indexPath: IndexPath, withDate date: DayDate) {

        var label: UILabel!
        if !discardedDayLabels.isEmpty {
            label = discardedDayLabels.remove(at: 0)
            label.frame = Util.generateDayLabelFrame(forIndex: indexPath)
        }
        else {
            label = Util.makeDayLabel(withIndexPath: indexPath)
        }

        if let newFontSize = Util.assignTextAndResizeFont(forLabel: label, andDate: date) {
            FontVariables.dayLabelCurrentFontSize = newFontSize
            updateVisibleLabels()
        }
        visibleDayLabels[date] = label
        self.topBarView.addSubview(label)
    }

    func discardLabel(withDate date: DayDate) {

        if let label = visibleDayLabels[date] {
            label.removeFromSuperview()
            visibleDayLabels.removeValue(forKey: date)
            discardedDayLabels.append(label)
        }
        trashExcessDayLabels()
    }

    func addAllDayEvents(_ events: [EventData], forIndexPath indexPath: IndexPath, withDate dayDate: DayDate) {
        let extraHeight = LayoutVariables.allDayEventVerticalSpacing*2+LayoutVariables.allDayEventHeight

        if self.topBarHeight < extraHeight {
            self.extraTopBarHeight = extraHeight
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }

        if visibleAllDayEvents[dayDate] != nil {
            for (_, layer) in visibleAllDayEvents[dayDate]! {
                layer.removeFromSuperlayer()
            }
            visibleAllDayEvents[dayDate] = nil
        }

        let max = events.count
        var i = 0
        var layers: [EventData: CAShapeLayer] = [:]
        for event in events {
            let frame = Util.generateAllDayEventFrame(forIndex: indexPath, at: i, max: max)
            let layer = Util.makeEventLayer(withData: event, andFrame: frame)
            self.topBarView.layer.addSublayer(layer)
            layers[event] = layer

            i += 1
        }
        self.visibleAllDayEvents[dayDate] = layers
    }

    func discardAllDayEvents(forDate dayDate: DayDate) {
        if visibleAllDayEvents[dayDate] != nil {
            for (_, layer) in visibleAllDayEvents[dayDate]! {
                layer.removeFromSuperlayer()
            }
            visibleAllDayEvents[dayDate] = nil
        }

        if visibleAllDayEvents.isEmpty && self.topBarHeight > LayoutVariables.defaultTopBarHeight {
            self.extraTopBarHeight = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }
    }

    func hasAllDayEvents(forDate dayDate: DayDate) -> Bool {
        return (visibleAllDayEvents[dayDate] != nil)
    }

    func tapTopBar(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(ofTouch: 0, in: self.topBarView)
        for (_, eventLayers) in visibleAllDayEvents {
            for (event, layer) in eventLayers {
                if layer.path!.contains(touchPoint) {
                    eventViewWasTapped(event)
                }
            }
        }
    }

    func updateVisibleLabelsAndMainConstraints() {
        resetFontValues()
        updateTopAndSideBarConstraints()
        updateVisibleLabels()
    }

    func updateTopAndSideBarPositions() {
        sideBarYPositionConstraint.constant = -dayScrollView.contentOffset.y + sideBarTopBuffer
        topBarXPositionConstraint.constant = -dayScrollView.dayCollectionView.contentOffset.x + topBarLeftBuffer
    }

    func eventViewWasTapped(_ eventData: EventData) {
        self.delegate?.didTapEvent(in: self, eventId: eventData.id)
    }

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell, at hours: Int, and minutes: Int) {
        let date = dayViewCell.date.getDateWithTime(hours: hours, minutes: minutes, seconds: 0)
        self.delegate?.didLongPressDayView(in: self, atDate: date)
    }

    func requestEvents(between startDate: DayDate, and endDate: DayDate) {
        self.delegate?.loadNewEvents(in: self, between: startDate.dateObj, and: endDate.dateObj)
    }

    // MARK: - PRIVATE/HELPER FUNCTIONS -

    private func updateTopAndSideBarConstraints() {

        // Height of total side bar
        let dayViewCellHeight = LayoutVariables.dayViewCellHeight
        let dayViewCellHourHeight = dayViewCellHeight/DateSupport.hoursInDay
        let sideBarHeight = dayViewCellHeight + dayViewCellHourHeight

        // Set position and size constraints for side bar and hour view
        self.hourSideBarBottomConstraint.constant = dayViewCellHourHeight
        self.sideBarHeightConstraint.constant = sideBarHeight
        self.sideBarTopBuffer = LayoutVariables.dayViewVerticalSpacing - dayViewCellHourHeight/2

        // Set correct size and constraints of top bar view
        updateTopBarHeight()
        self.topBarWidthConstraint.constant = dayScrollView.dayCollectionView.contentSize.width
        self.topBarLeftBuffer = sideBarView.frame.width
        updateTopAndSideBarPositions()
    }

    private func updateVisibleLabels() {
        for cell in dayScrollView.dayCollectionView.visibleCells {
            let indexPath = dayScrollView.dayCollectionView.indexPath(for: cell)!
            if let dayViewCell = cell as? DayViewCell {
                let dayDate = dayViewCell.date

                if let label = visibleDayLabels[dayDate] {
                    label.frame = Util.generateDayLabelFrame(forIndex: indexPath)
                    label.font = FontVariables.dayLabelCurrentFont
                    label.textColor = FontVariables.dayLabelTextColor
                    if let newFontSize = Util.assignTextAndResizeFont(forLabel: label, andDate: dayDate) {
                        FontVariables.dayLabelCurrentFontSize = newFontSize
                        updateVisibleLabels()
                    }
                }
            }
        }
        trashExcessDayLabels()
        updateDiscardedLabels()
    }

    private func updateDiscardedLabels() {
        for label in discardedDayLabels {
            label.font = FontVariables.dayLabelCurrentFont
            label.textColor = FontVariables.dayLabelTextColor
        }
    }

    private func trashExcessDayLabels() {
        let maxAllowed = Int(LayoutVariables.visibleDays)

        if discardedDayLabels.count > maxAllowed {
            let overflow = discardedDayLabels.count - maxAllowed
            for i in 0...overflow {
                discardedDayLabels.remove(at: i)
            }
        }
    }

    private func resetFontValues() {
        FontVariables.dayLabelCurrentFontSize = FontVariables.dayLabelDefaultFont.pointSize
        Util.resetDayLabelTextMode()
    }

}

/**
 This extension makes it so that topBarHeight can not be directly set, and will
 only be updated when either the extra top bar height is changed or the updateTopBarHeight function is called.
 */
extension WeekView {

    fileprivate func updateTopBarHeight() {
        self.topBarHeight = self.extraTopBarHeight + LayoutVariables.defaultTopBarHeight
    }

    /**
     Extra height added on to default top bar height.
     */
    fileprivate(set) var extraTopBarHeight: CGFloat {
        get {
            return self.topBarHeight - LayoutVariables.defaultTopBarHeight
        }
        set (extraHeight) {
            self.topBarHeight = LayoutVariables.defaultTopBarHeight + extraHeight
        }
    }

    /**
     Height of top bar.
     */
    private(set) var topBarHeight: CGFloat {
        get {
            return self.topBarView.frame.height
        }
        set(height) {
            self.topBarHeightConstraint.constant = height
            self.topLeftBufferHeightConstraint.constant = height
        }
    }

}

// MARK: - WEEKVIEW DELEGATE -

@objc public protocol WeekViewDelegate: class {
    func didLongPressDayView(in weekView: WeekView, atDate date: Date)

    func didTapEvent(in weekView: WeekView, eventId: String)

    func loadNewEvents(in weekView: WeekView, between startDate: Date, and endDate: Date)

}

// MARK: - WEEKVIEW LAYOUT VARIABLES -

public struct FontVariables {

    // Minimum font for all day labels
    fileprivate(set) static var dayLabelCurrentFontSize = LayoutDefaults.dayLabelFont.pointSize {
        didSet {
            updateDayLabelCurrentFont()
        }
    }

}
