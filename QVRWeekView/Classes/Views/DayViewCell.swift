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
    
    // MARK: - INITIALIZERS & OVERRIDES -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        date = nil
        if events != nil && events.count != 0 {
            for event in events.values {
                if let eventView = eventViews[event[EventKeys.id]!] {
                    eventView.removeFromSuperview()
                }
            }
        }
        events = nil
        eventViews = nil
        if hourIndicatorView != nil {
            hourIndicatorView.removeFromSuperview()
            hourIndicatorView = nil
        }
        if overlayView != nil {
            overlayView.removeFromSuperview()
            overlayView = nil
        }
    }
    
    func setDate(`as` date:Date) {
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
            self.backgroundColor = LayoutDefaults.weekendDayViewColor
        }
        else {
            self.backgroundColor = LayoutDefaults.defaultDayViewColor
        }
    }
    
    func setEventViews(_ events:[[String:String]]) {
        
        self.events = [:]
        self.eventViews = [:]
        for event in events {
            let id = event[EventKeys.id]!
            self.events[id] = event
            let duration = Int(event[EventKeys.duration]!)!
            let time = Int(event[EventKeys.time]!)!
            let eventView = EventView(frame: getFrame(withStartingTime: time, andDuration: duration))
            eventView.textLabel.text = event[EventKeys.title]
            self.addSubview(eventView)
            eventViews[event[EventKeys.id]!] = eventView
        }
    }
    
    private func generateOverlay() {
        
        overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: bottomDistancePercent*self.bounds.height))
        overlayView.backgroundColor = LayoutDefaults.overlayColor
        
        hourIndicatorView = UIView(frame: CGRect(x: 0, y: overlayView.frame.height, width: self.bounds.width, height: 4))
        hourIndicatorView.backgroundColor = UIColor.black
        hourIndicatorView.layer.cornerRadius = 2.5
        overlayView.addSubview(hourIndicatorView)
        
        self.addSubview(overlayView)
    }
    
    private func updateOverlay() {
        
        if isOverlayHidden {
            print(self.subviews)
            if hourIndicatorView != nil {
                hourIndicatorView.removeFromSuperview()
                hourIndicatorView = nil
            }
            if overlayView != nil {
                overlayView.removeFromSuperview()
                overlayView = nil
            }
        }
        else {
            overlayView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: bottomDistancePercent*self.bounds.height)
            if isHourIndicatorHidden && hourIndicatorView != nil{
                hourIndicatorView.removeFromSuperview()
                hourIndicatorView = nil
            }
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
        
        let hourHeight = self.bounds.height/24
        let dottedPathCombine = CGMutablePath()
        let linePathCombine = CGMutablePath()
        
        // Generate dotted line seperators
        for i in 0...DateSupport.hoursInDay-1 {
            
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
        
        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.path=dottedPathCombine
        dottedLineLayer.lineDashPattern = [3,1]
        dottedLineLayer.lineWidth = 1
        dottedLineLayer.fillColor = UIColor.clear.cgColor
        dottedLineLayer.opacity = 1.0
        dottedLineLayer.strokeColor = LayoutDefaults.backgroundGray.cgColor
        
        let lineLayer = CAShapeLayer()
        lineLayer.path=linePathCombine
        lineLayer.lineWidth = 1
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = LayoutDefaults.backgroundGray.cgColor
        
        shapeLayers.append(dottedLineLayer)
        shapeLayers.append(lineLayer)
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(dottedLineLayer)
    }
    
    private func getFrame(withStartingTime time:Int,andDuration duration:Int) -> CGRect{
        let hourHeight = self.bounds.height/24
        return CGRect(x: 0, y: hourHeight*CGFloat(time), width: self.bounds.width, height: hourHeight*CGFloat(duration))
    }

}
