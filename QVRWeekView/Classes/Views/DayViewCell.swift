import Foundation
import UIKit

/**
 Class of the day view columns generated and displayed within DayScrollView
 */
class DayViewCell: UICollectionViewCell {

    private let dequeCellId = Int(drand48()*10000)

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
    // PRevious height
    private var prevHeight: CGFloat?

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
        for eventLayer in self.eventLayers {
            eventLayer.removeFromSuperlayer()
        }
        self.date = DayDate()
        self.overlayView = nil
        self.hourIndicatorView = nil
        self.eventsData.removeAll()
        self.eventFrames.removeAll()
        self.eventLayers.removeAll()
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
        let frameCalc = FrameCalculator(withWidth: self.frame.width, andHeight: self.frame.height)
//        print("Queued for calc \(date) on cell \(dequeCellId)")
        DispatchQueue.global(qos: .userInitiated).async {
//            print("Performing calc \(self.date) on cell \(self.dequeCellId)")
            self.eventFrames = frameCalc.calculate(withData: eventsData)
            DispatchQueue.main.async {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
//            print("Finished calc \(self.date) on cell \(self.dequeCellId)")
        }
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

        // Remove all shape and text layers from superlayer
        for layer in self.eventLayers {
            layer.removeFromSuperlayer()
        }
        self.eventLayers.removeAll()

        var factorChange = CGFloat(1)
        let newHeight = self.frame.height
        if prevHeight == nil {
            prevHeight = newHeight
        }
        else {
            factorChange = newHeight / prevHeight!
        }

        // Generate event rectangle shape layers and text layers
        for (id, frame) in self.eventFrames {

            guard eventsData[id] != nil else {
                return
            }

            let eventRectLayer = CAShapeLayer()
            var transform = CGAffineTransform(scaleX: 1.0, y: factorChange)
            eventRectLayer.path = CGPath(rect: frame, transform: &transform)
            eventRectLayer.fillColor = eventsData[id]!.color.cgColor

            let eventTextLayer = CATextLayer()
            eventTextLayer.frame = frame.applying(transform)
            eventTextLayer.string = eventsData[id]!.title
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
}

protocol DayViewCellDelegate: class {

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell)

    func eventViewWasTappedIn(_ dayViewCell: DayViewCell, withEventData eventData: EventData)

}
