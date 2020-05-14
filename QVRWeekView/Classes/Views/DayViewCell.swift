import Foundation
import UIKit

/**
 Class of the day view columns generated and displayed within DayScrollView
 */
class DayViewCell: UICollectionViewCell, CAAnimationDelegate {

    // Static variable stores all ids of dayviewcells
    private static var uniqueIds: [Int] = []

    // Date and event variables
    private(set) var date: DayDate = DayDate()
    private var eventsData: [String: EventData] = [:]
    private var eventFrames: [String: CGRect] = [:]

    // Overlay variables
    private var bottomDistancePercent = CGFloat(0)
    private var overlayView: UIView = UIView()
    private var hourIndicatorView: UIView = UIView()

    // separator shape layers
    private var separatorLayers: [CAShapeLayer] = []
    // Event rectangle shape layers
    private var eventLayers: [EventLayer] = []
    // Layer of the preview event
    private var previewLayer: CALayer?
    // Stores if preview should be currently visible or not
    private var previewVisible: Bool = false
    // Previous height
    private var lastResizeHeight: CGFloat!
    // Previous width
    private var lastResizeWidth: CGFloat!
    // Height of an hour
    private var hourHeight: CGFloat {
        return self.bounds.height/DateSupport.hoursInDay
    }

    // Delegate variable
    weak var delegate: DayViewCellDelegate?
    // Unique day view cell id
    let id: Int = DayViewCell.genUniqueId()
    // Flag storing if event is being added or not
    var addingEvent: Bool = false
    // Customisable layout object. Starts with default, but soon replaced.
    var layout: DayViewCellLayout = DayViewCellLayout()

    // MARK: - INITIALIZERS & OVERRIDES -

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    private func initialize() {
        // Initialization
        self.clipsToBounds = true
        self.backgroundColor = layout.defaultDayViewColor
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        self.lastResizeHeight = self.frame.height
        self.lastResizeWidth = self.frame.width
        // Setup overlay
        self.hourIndicatorView.layer.cornerRadius = 1
        self.overlayView.addSubview(hourIndicatorView)
        self.addSubview(overlayView)
    }

    override func layoutSubviews() {
        updateTimeView()
        generateSeparatorLayers()
        generateEventLayers()
        if self.addingEvent {
            self.addingEvent = false
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }

    func clearValues() {
        for eventLayer in self.eventLayers {
            eventLayer.removeFromSuperlayer()
        }
        self.date = DayDate()
        self.eventsData.removeAll()
        self.eventFrames.removeAll()
        self.eventLayers.removeAll()
        setNeedsLayout()
        layoutIfNeeded()
    }

    func setDate(`as` date: DayDate) {
        self.date = date
        updateTimeView()
    }

    func updateTimeView() {
        if date.isToday() {
            self.overlayView.isHidden = !self.layout.showTimeOverlay
            self.bottomDistancePercent = DateSupport.getPercentTodayPassed()
            self.backgroundColor = self.layout.todayViewColor
        } else {
            self.overlayView.isHidden = true
            if date.hasPassed() {
                self.backgroundColor = date.isWeekend() ? self.layout.passedWeekendDayViewColor : self.layout.passedDayViewColor
            }
            else {
                self.backgroundColor = date.isWeekend() ? self.layout.weekendDayViewColor : self.layout.defaultDayViewColor
            }
        }
        updateOverlay()
    }

    func setEventsData(_ eventsData: [String: EventData], andFrames eventFrames: [String: CGRect]) {
        self.eventsData = eventsData
        self.eventFrames = eventFrames
        // Resize event frames from standard size to current size
        let scaleY = self.frame.height / LayoutDefaults.dayViewCellHeight
        let scaleX = self.frame.width / LayoutDefaults.dayViewCellWidth
        for (id, frame) in self.eventFrames {
            self.eventFrames[id] = frame.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        }
        lastResizeWidth = self.frame.width
        lastResizeHeight = self.frame.height
        // Update UI
        self.generateEventLayers()
    }

    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        for (id, frame) in eventFrames {
            if frame.contains(tapPoint) && eventsData[id] != nil {
                self.delegate?.eventViewWasTappedIn(self, withEventData: eventsData[id]!)
                return
            }
        }
    }

    private func updateOverlay() {
        if !self.overlayView.isHidden {
            overlayView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.bounds.width,
                                       height: bottomDistancePercent*self.bounds.height)
            overlayView.backgroundColor = date.isWeekend() ? self.layout.passedWeekendDayViewColor : self.layout.passedDayViewColor
            hourIndicatorView.frame = CGRect(x: 0,
                                             y: overlayView.frame.height-self.layout.hourIndicatorThickness/2,
                                             width: self.bounds.width,
                                             height: self.layout.hourIndicatorThickness)
            hourIndicatorView.backgroundColor = self.layout.hourIndicatorColor
        }

    }

    private func generateSeparatorLayers() {
        // Clear old separators
        for layer in self.separatorLayers {
            layer.removeFromSuperlayer()
        }
        self.separatorLayers.removeAll()

        let dottedPathCombine = CGMutablePath()
        let linePathCombine = CGMutablePath()

        // Generate line separator paths
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

        // Generate line separator shape layers
        let lineLayer = CAShapeLayer()
        lineLayer.path=linePathCombine
        lineLayer.lineWidth = self.layout.mainSeparatorThickness
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = self.layout.mainSeparatorColor.cgColor

        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.path=dottedPathCombine
        dottedLineLayer.lineDashPattern = self.layout.dashedSeparatorPattern
        dottedLineLayer.lineWidth = self.layout.dashedSeparatorThickness
        dottedLineLayer.fillColor = UIColor.clear.cgColor
        dottedLineLayer.opacity = 1.0
        dottedLineLayer.strokeColor = self.layout.dashedSeparatorColor.cgColor

        // Add separator layers as sublayers
        self.separatorLayers.append(dottedLineLayer)
        self.separatorLayers.append(lineLayer)
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(dottedLineLayer)
    }

    private func generateEventLayers() {
        // Remove all shape and text layers from superlayer
        for layer in self.eventLayers {
            layer.removeFromSuperlayer()
        }
        self.eventLayers.removeAll()

        let scaleY = self.frame.height/lastResizeHeight
        let scaleX = self.frame.width/lastResizeWidth
        lastResizeHeight = self.frame.height
        lastResizeWidth = self.frame.width

        // Generate event rectangle shape layers and text layers
        for (id, frame) in self.eventFrames {
            guard let event = eventsData[id] else {
                continue
            }

            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            var newFrame = frame
            if scaleY != 1.0 || scaleX != 1.0 {
                newFrame = frame.applying(transform)
                self.eventFrames[id] = newFrame
            }
            let eventLayer = EventLayer(withFrame: newFrame, layout: self.layout, andEvent: event)
            self.layout.eventStyleCallback?(eventLayer, event)
            self.eventLayers.append(eventLayer)
            self.layer.addSublayer(eventLayer)
        }
        if let pLayer = self.previewLayer {
            pLayer.removeFromSuperlayer()
            if previewVisible {
                self.layer.addSublayer(pLayer)
            }
        }
    }

    @objc func longPressAction(_ sender: UILongPressGestureRecognizer) {
        guard !self.addingEvent else {
            return
        }

        let yTouch = sender.location(ofTouch: 0, in: self).y
        let previewPos = self.previewPosition(forYCoordinate: yTouch)

        if sender.state == .began {
            self.makePreviewLayer(at: previewPos)
        }
        else if sender.state == .ended {
            self.releasePreviewLayer(at: previewPos)
        }
        else if sender.state == .changed {
            movePreviewLayer(to: previewPos)
        } else if sender.state == .cancelled || sender.state == .failed {
            self.previewVisible = false
        }
    }

    private func makePreviewLayer(at position: CGPoint) {
        removePreviewLayer()

        let startingBounds = CGRect(origin: position, size: CGSize(width: 0, height: 0))
        let endingBounds = CGRect(origin: position, size: CGSize(width: self.frame.width, height: hourHeight*CGFloat(self.layout.previewEventHourHeight)))

        let previewLayer = CALayer()
        previewLayer.frame = startingBounds
        previewLayer.backgroundColor = self.layout.previewEventColor.cgColor
        previewLayer.masksToBounds = true

        let textLayer = CATextLayer()
        textLayer.frame = endingBounds
        let mainFontAttributes: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): self.layout.eventLabelFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): self.layout.eventLabelTextColor.cgColor]
        let mainAttributedString = NSMutableAttributedString(string: self.layout.previewEventText, attributes: convertToOptionalNSAttributedStringKeyDictionary(mainFontAttributes))
        textLayer.string = mainAttributedString
        textLayer.isWrapped = true
        textLayer.contentsScale = UIScreen.main.scale

        previewLayer.addSublayer(textLayer)
        self.layout.eventStyleCallback?(previewLayer, nil)
        self.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        self.previewVisible = self.layout.showPreview

        let anim = CABasicAnimation(keyPath: "bounds")
        anim.duration = 0.15
        anim.fromValue = startingBounds
        anim.toValue = endingBounds

        previewLayer.bounds = endingBounds
        previewLayer.add(anim, forKey: "bounds")
    }

    private func movePreviewLayer(to position: CGPoint) {
        if let layer = self.previewLayer {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            layer.position = position
            CATransaction.commit()
        }
    }

    func releasePreviewLayer(at position: CGPoint) {
        if let prevLayer = self.previewLayer {
            let anim = CABasicAnimation(keyPath: "position")
            let rounded = CGFloat(Double(position.y/hourHeight).roundToNearest(self.layout.previewEventMinutePrecision / 60.0))*hourHeight
            let roundedPos = CGPoint(x: position.x, y: rounded)
            anim.duration = 0.20
            anim.fromValue = prevLayer.position
            anim.toValue = roundedPos
            anim.delegate = self
            prevLayer.position = roundedPos
            prevLayer.add(anim, forKey: "position")
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Animation is either finished, or preview is not visible
        if let prevLayer = self.previewLayer, (flag || !previewVisible) {
            let time = Double( ((prevLayer.position.y-(hourHeight*CGFloat(self.layout.previewEventHourHeight / 2)))/self.frame.height)*24 )
            let rounded = time.roundToNearest(self.layout.previewEventMinutePrecision / 60.0)
            let hours = Int(rounded)
            let minutes = Int((rounded-Double(hours))*60.0)

            self.previewVisible = false
            self.delegate?.dayViewCellWasLongPressed(self, hours: hours, minutes: minutes)
        }

    }

    func removePreviewLayer() {
        if let previousPreview = self.previewLayer {
            previousPreview.removeFromSuperlayer()
            self.previewLayer = nil
            self.previewVisible = false
        }
    }

    private func previewPosition(forYCoordinate yCoord: CGFloat) -> CGPoint {
        return CGPoint(x: self.frame.width/2, y: yCoord)
    }

    private static func genUniqueId() -> Int {
        var id: Int!
        repeat {
            id = Int(drand48()*100000)
        } while uniqueIds.contains(id)
        uniqueIds.append(id)
        return id
    }

}

protocol DayViewCellDelegate: class {

    func dayViewCellWasLongPressed(_ dayViewCell: DayViewCell, hours: Int, minutes: Int)

    func eventViewWasTappedIn(_ dayViewCell: DayViewCell, withEventData eventData: EventData)

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
