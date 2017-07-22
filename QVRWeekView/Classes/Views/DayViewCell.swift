import Foundation
import UIKit

/**
 Class of the day view columns generated and displayed within DayScrollView
 */
class DayViewCell : UICollectionViewCell {
    
    // Date and event variables
    private(set) var date:Date!
    private(set) var events:[String:[String:String]]!
    private var eventViews:[String:EventView]!
    
    // Overlay variables
    private var isOverlayHidden:Bool = true
    private var isHourIndicatorHidden:Bool = true
    private var bottomDistancePercent = CGFloat(0)
    private var overlayView: UIView!
    private var hourIndicatorView: UIView!

    // Seperator drawing variables
    private var shapeLayers:[CAShapeLayer] = []
    
    // Delegate variable
    weak var delegate: DayViewCellDelegate?
    
    // MARK: - INITIALIZERS & OVERRIDES -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        self.clipsToBounds = true
        self.backgroundColor = LayoutDefaults.defaultDayViewColor
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction)))
    }
    
    override func layoutSubviews() {
        
        generateSeperators()
        updateOverlay()
        updateEventFrames()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    func clearValues() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        date = nil
        events = nil
        eventViews = nil
        overlayView = nil
        hourIndicatorView = nil
    }
    
    func setDate(`as` date: Date) {
        
        if overlayView != nil {
            overlayView.removeFromSuperview()
            overlayView = nil
        }
        if hourIndicatorView != nil {
            hourIndicatorView.removeFromSuperview()
            hourIndicatorView = nil
        }
        
        self.date = date
        
        if date.hasPassed() {
            isOverlayHidden = false
            
            // If is today
            if date.isToday() {
                bottomDistancePercent = date.getPercentDayPassed()
                isHourIndicatorHidden = false
            }
            else {
                bottomDistancePercent = 1.0
                isHourIndicatorHidden = true
            }
            generateOverlay()
        }
        else {
            isOverlayHidden = true
        }
        
        updateOverlay()
        
        if date.isWeekend() {
            self.backgroundColor = LayoutVariables.weekendDayViewColor
        }
        else {
            self.backgroundColor = LayoutVariables.defaultDayViewColor
        }
    }
    
    func setEventViews(_ events: [[String:String]], withDayScrollView dayScrollView: DayScrollView) {
        
        self.events = [:]
        self.eventViews = [:]
        for event in events {
            let id = event[EventKeys.id]!
            self.events[id] = event
            let duration = Int(event[EventKeys.duration]!)!
            let time = Int(event[EventKeys.time]!)!
            let eventView = EventView(frame: getFrame(withStartingTime: time, andDuration: duration))
            eventView.textLabel.text = event[EventKeys.title]
            eventView.delegate = dayScrollView
            self.addSubview(eventView)
            eventViews[event[EventKeys.id]!] = eventView
        }
    }
    
    func longPressAction(_ sender: UILongPressGestureRecognizer) {
        
        if (sender.state == .began) {
            delegate?.dayViewCellWasLongPressed(self)
        }
    }
    
    private func generateOverlay() {
        
        if !isOverlayHidden {
            
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: bottomDistancePercent*self.bounds.height))

            if !isHourIndicatorHidden {
                let thickness = LayoutVariables.hourIndicatorThickness
                hourIndicatorView = UIView(frame: CGRect(x: 0, y: overlayView.frame.height-thickness/2, width: self.bounds.width, height: thickness))
                hourIndicatorView.layer.cornerRadius = 1
                overlayView.addSubview(hourIndicatorView)
            }
            self.addSubview(overlayView)
        }
        updateOverlay()
    }
    
    private func updateOverlay() {
        if !isOverlayHidden {
            overlayView.frame = CGRect(x: overlayView.frame.origin.x, y: overlayView.frame.origin.y, width: self.bounds.width, height: bottomDistancePercent*self.bounds.height)
            overlayView.backgroundColor = LayoutVariables.overlayColor
            if !isHourIndicatorHidden {
                hourIndicatorView.frame = CGRect(x: hourIndicatorView.frame.origin.x, y: overlayView.frame.height-LayoutVariables.hourIndicatorThickness/2, width: self.bounds.width, height: hourIndicatorView.frame.height)
                hourIndicatorView.backgroundColor = LayoutVariables.hourIndicatorColor
            }
            self.bringSubview(toFront: overlayView)
        }
    }
    
    private func updateEventFrames() {
    
        guard eventViews != nil else {
            return
        }
        for eventView in eventViews {
            let id = eventView.key
            let eventData = events[id]!
            let time = Int(eventData[EventKeys.time]!)!
            let duration = Int(eventData[EventKeys.duration]!)!
            eventView.value.frame = getFrame(withStartingTime: time, andDuration: duration)
            self.bringSubview(toFront: eventView.value)
        }
    }

    
    private func generateSeperators() {
        // Clear old seperators
        for layer in shapeLayers {
            layer.removeFromSuperlayer()
        }
        shapeLayers = []
        
        let hourHeight = self.bounds.height/DateSupport.hoursInDay
        let dottedPathCombine = CGMutablePath()
        let linePathCombine = CGMutablePath()
        
        // Generate dotted line seperators
        for i in 0...Int(DateSupport.hoursInDay)-1 {
            
            let dottedPath = UIBezierPath()
            let linePath = UIBezierPath()
            
            let y1 = hourHeight*CGFloat(i)
            let y2 = hourHeight*CGFloat(i) + hourHeight/2
            
            linePath.move(to: CGPoint(x: 0, y: y1))
            dottedPath.move(to: CGPoint(x: 0, y: y2))
            linePath.addLine(to: CGPoint(x: self.frame.width, y: y1))
            dottedPath.addLine(to: CGPoint(x: self.frame.width, y: y2))
            
            linePathCombine.addPath(linePath.cgPath)
            dottedPathCombine.addPath(dottedPath.cgPath)
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path=linePathCombine
        lineLayer.lineWidth = LayoutVariables.mainSeperatorThickness
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = LayoutVariables.mainSeperatorColor.cgColor
        
        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.path=dottedPathCombine
        dottedLineLayer.lineDashPattern = LayoutVariables.dashedSeperatorPattern
        dottedLineLayer.lineWidth = LayoutVariables.dashedSeperatorThickness
        dottedLineLayer.fillColor = UIColor.clear.cgColor
        dottedLineLayer.opacity = 1.0
        dottedLineLayer.strokeColor = LayoutVariables.dashedSeperatorColor.cgColor
        
        shapeLayers.append(dottedLineLayer)
        shapeLayers.append(lineLayer)
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(dottedLineLayer)
    }
    
    private func getFrame(withStartingTime time:Int,andDuration duration:Int) -> CGRect{
        let hourHeight = self.bounds.height/DateSupport.hoursInDay
        return CGRect(x: 0, y: hourHeight*CGFloat(time), width: self.bounds.width, height: hourHeight*CGFloat(duration))
    }

}

protocol DayViewCellDelegate: class {
    
    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell)
    
}
