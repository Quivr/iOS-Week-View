import Foundation
import UIKit

/**
 Class of the day view columns generated and displayed within DayScrollView
 */
class DayViewCell: UICollectionViewCell {

    // Date and event variables
    private(set) var date: DayDate = DayDate()
    private var eventsData: [Int: EventData] = [:]
    private var eventFrames: [Int: CGRect] = [:]

    // Overlay variables
    private var isOverlayHidden: Bool = true
    private var isHourIndicatorHidden: Bool = true
    private var bottomDistancePercent = CGFloat(0)
    private var overlayView: UIView!
    private var hourIndicatorView: UIView!

    // Seperator shape layers
    private var seperatorLayers: [CAShapeLayer] = []
    // Event rectangle shape layers
    private var eventLayers: [CALayer] = []

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
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }

    override func layoutSubviews() {
        generateSeperatorLayers()
        generateEventLayers()
        updateOverlay()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }

    func clearValues() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.date = DayDate()
        self.overlayView = nil
        self.hourIndicatorView = nil
        self.eventsData.removeAll()

        clearEventLayers()
    }

    func setDate(`as` date: DayDate) {

        self.date = date

        updateTimeView()

        if date.isWeekend() {
            self.backgroundColor = LayoutVariables.weekendDayViewColor
        }
        else {
            self.backgroundColor = LayoutVariables.defaultDayViewColor
        }
    }

    func updateTimeView() {

        if overlayView != nil {
            self.overlayView.removeFromSuperview()
            self.overlayView = nil
        }
        if hourIndicatorView != nil {
            self.hourIndicatorView.removeFromSuperview()
            self.hourIndicatorView = nil
        }

        if self.date.hasPassed() {
            self.isOverlayHidden = false
            // If is today
            if date.isToday() {
                self.bottomDistancePercent = DateSupport.getPercentTodayPassed()
                self.isHourIndicatorHidden = false
            }
            else {
                self.bottomDistancePercent = 1.0
                self.isHourIndicatorHidden = true
            }
            generateOverlay()
        }
        else {
            isOverlayHidden = true
        }
        updateOverlay()
    }

    func setEventsData(_ eventsData: [Int:EventData]) {
        self.eventsData = eventsData
        generateEventLayers()
    }

    func longPressAction(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began {
            self.delegate?.dayViewCellWasLongPressed(self)
        }
    }

    func tapAction(_ sender: UITapGestureRecognizer) {

        let tapPoint = sender.location(in: self)

        for (id, frame) in eventFrames {
            if frame.contains(tapPoint) {
                self.delegate?.eventViewWasTappedIn(self, withEventData: eventsData[id]!)
            }
        }
    }

    private func generateOverlay() {

        if !isOverlayHidden {
            self.overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: bottomDistancePercent*self.bounds.height))

            if !isHourIndicatorHidden {
                let thickness = LayoutVariables.hourIndicatorThickness
                self.hourIndicatorView = UIView(frame: CGRect(x: 0, y: overlayView.frame.height-thickness/2, width: self.bounds.width, height: thickness))
                self.hourIndicatorView.layer.cornerRadius = 1
                self.overlayView.addSubview(hourIndicatorView)
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

    private func generateSeperatorLayers() {
        // Clear old seperators
        for layer in self.seperatorLayers {
            layer.removeFromSuperlayer()
        }
        self.seperatorLayers.removeAll()

        let hourHeight = self.bounds.height/DateSupport.hoursInDay
        let dottedPathCombine = CGMutablePath()
        let linePathCombine = CGMutablePath()

        // Generate line seperator paths
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

        // Generate line seperator shape layers
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

        // Add seperator layers as sublayers
        self.seperatorLayers.append(dottedLineLayer)
        self.seperatorLayers.append(lineLayer)
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(dottedLineLayer)
    }

    private func generateEventLayers() {

        // Clear all rectangles
        clearEventLayers()
        // Calculate frames for events
        calculateEventFrames()

        // Generate event rectangle shape layers and text layers
        for (id, data) in self.eventsData {

            let eventRectLayer = CAShapeLayer()
            eventRectLayer.path = CGPath(rect: eventFrames[id]!, transform: nil)
            eventRectLayer.fillColor = data.color.cgColor

            let eventTextLayer = CATextLayer()
            eventTextLayer.frame = frame
            eventTextLayer.string = data.title
            let font = FontVariables.eventLabelFont
            let ctFont: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
            eventTextLayer.font = ctFont
            eventTextLayer.fontSize = font.pointSize
            eventTextLayer.isWrapped = true
            eventTextLayer.contentsScale = UIScreen.main.scale

            self.eventLayers.append(eventRectLayer)
            self.eventLayers.append(eventTextLayer)
            self.layer.addSublayer(eventRectLayer)
            self.layer.addSublayer(eventTextLayer)
        }
    }

    private func clearEventLayers() {
        // Remove all shape and text layers from superlayer
        for layer in self.eventLayers {
            layer.removeFromSuperlayer()
        }
        self.eventLayers.removeAll()
        self.eventFrames.removeAll()
    }

    private func calculateEventFrames() {

        var endPoints: [EndPoint] = []
        var finalFrameState: [EventFrame] = []
        var sweepState: [Int: EventFrame] = [:]

        for (id, data) in eventsData {
            let frame = getEventFrame(withData: data)
            endPoints.append(EndPoint(y: frame.y, id: id, frame: frame, isStart: true))
            endPoints.append(EndPoint(y: frame.y2, id: id, frame: frame, isStart: false))
        }

        endPoints.sort(by: {(e1, e2) -> Bool in
            if e1.y == e2.y {
                if e1.isEnd && e2.isStart {
                    return true
                }
                else if e1.isStart && e2.isEnd {
                    return false
                }
            }
            return e1.y < e2.y
        })

        for point in endPoints {
            if point.isStart {
                // If collisions, resize and reposition the frames.
                if !sweepState.isEmpty {
                    var frames = Array(sweepState.values)
                    frames.append(point.frame)
                    frames.sort(by: {(f1, f2) -> Bool in
                        return f1.x < f2.x
                    })
                    var i = CGFloat(0)
                    let newWidth = self.frame.width/CGFloat(frames.count)
                    for frame in frames {
                        frame.x = newWidth*i
                        frame.width = newWidth
                        if frame.intersects(withFrameFrom: finalFrameState) {
                            frame.swapPositions(withFrame: point.frame)
                        }
                        i += 1
                    }
                }
                // Add to sweepingline
                sweepState[point.id] = point.frame
            }
            else {
                // Remove from sweepingline and add to eventFrames
                sweepState[point.id] = nil
                finalFrameState.append(point.frame)
                finalFrameState.sort(by: {(f1, f2) -> Bool in
                     return f1.x < f2.x
                })
                eventFrames[point.id] = point.frame.cgRect
            }
        }
    }

    private func getEventFrame(withData data: EventData) -> EventFrame {
        let time = data.startDate.getHMSTime()
        let duration = data.endDate.getHMSTime() - data.startDate.getHMSTime()
        let hourHeight = self.bounds.height/DateSupport.hoursInDay
        return EventFrame(x: 0, y: hourHeight*CGFloat(time), width: self.bounds.width, height: hourHeight*CGFloat(duration), id: data.id)
    }

    private struct EndPoint {
        var y: CGFloat
        var id: Int
        var frame: EventFrame
        var isStart: Bool
        var isEnd: Bool {
            return !isStart
        }
    }

    private class EventFrame: CustomStringConvertible {

        init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, id: Int) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
            self.id = id
        }

        let id: Int
        var x: CGFloat
        var y: CGFloat
        var width: CGFloat
        var height: CGFloat
        var leftLimit: CGFloat?
        var rightLimit: CGFloat?

        var y2: CGFloat {
            return self.y + self.height
        }

        var x2: CGFloat {
            return self.x + self.width
        }

        var description: String {
            return "{x: \(x), y: \(y), width: \(width), height: \(height)}\n"
        }

        var cgRect: CGRect {
            return CGRect(x: self.x, y: self.y, width: self.width, height: self.height)
        }

        func intersects(withFrameFrom eventFrames: [EventFrame]) -> Bool {
            for frame in eventFrames {
                if self.cgRect.intersects(frame.cgRect) {
                    return true
                }
            }
            return false
        }

        func swapPositions(withFrame eventFrame: EventFrame) {
            let oldX = self.x
            self.x = eventFrame.x
            eventFrame.x = oldX
        }
    }
}

protocol DayViewCellDelegate: class {

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell)

    func eventViewWasTappedIn(_ dayViewCell: DayViewCell, withEventData eventData: EventData)

}
