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
    private var eventLayers: [CAShapeLayer] = []
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

    private var layoutVariables: LayoutVariables {
        return delegate?.layoutVariables(for: self) ?? LayoutVariables()
    }

    // Delegate variable
    weak var delegate: DayViewCellDelegate?
    let id: Int
    var addingEvent: Bool = false

    // MARK: - INITIALIZERS & OVERRIDES -

    required init?(coder aDecoder: NSCoder) {
        self.id = DayViewCell.genUniqueId()
        super.init(coder: aDecoder)
        self.initialize()
    }

    override init(frame: CGRect) {
        self.id = DayViewCell.genUniqueId()
        super.init(frame: frame)
        self.initialize()
    }

    private func initialize() {
        // Initialization
        self.clipsToBounds = true
        self.backgroundColor = LayoutDefaults.defaultDayViewColor
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
        updateOverlay()
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
            self.overlayView.isHidden = false
            if layoutVariables.todayViewColor == layoutVariables.defaultDayViewColor {
                self.bottomDistancePercent = DateSupport.getPercentTodayPassed()
                self.backgroundColor = date.isWeekend() ? layoutVariables.weekendDayViewColor : layoutVariables.defaultDayViewColor
            } else {
                self.backgroundColor = layoutVariables.todayViewColor
            }
        } else {
            self.overlayView.isHidden = true
            if date.hasPassed() {
                self.backgroundColor = date.isWeekend() ? layoutVariables.passedWeekendDayViewColor : layoutVariables.passedDayViewColor
            }
            else {
                self.backgroundColor = date.isWeekend() ? layoutVariables.weekendDayViewColor : layoutVariables.defaultDayViewColor
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
        self.generateEventLayers(andResizeText: TextVariables.eventLabelFontResizingEnabled)
    }

    func tapAction(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        for (id, frame) in eventFrames {
            if frame.contains(tapPoint) && eventsData[id] != nil {
                self.delegate?.eventViewWasTappedIn(self, withEventData: eventsData[id]!)
                return
            }
        }
    }

    func updateEventTextFontSize() {
        self.generateEventLayers(andResizeText: TextVariables.eventLabelFontResizingEnabled)
    }

    private func updateOverlay() {
        if !self.overlayView.isHidden {
            overlayView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.bounds.width,
                                       height: bottomDistancePercent*self.bounds.height)
            overlayView.backgroundColor = date.isWeekend() ? layoutVariables.passedWeekendDayViewColor : layoutVariables.passedDayViewColor
            hourIndicatorView.frame = CGRect(x: 0,
                                             y: overlayView.frame.height-layoutVariables.hourIndicatorThickness/2,
                                             width: self.bounds.width,
                                             height: layoutVariables.hourIndicatorThickness)
            hourIndicatorView.backgroundColor = layoutVariables.hourIndicatorColor
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
        lineLayer.lineWidth = layoutVariables.mainSeparatorThickness
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = layoutVariables.mainSeparatorColor.cgColor

        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.path=dottedPathCombine
        dottedLineLayer.lineDashPattern = layoutVariables.dashedSeparatorPattern
        dottedLineLayer.lineWidth = layoutVariables.dashedSeparatorThickness
        dottedLineLayer.fillColor = UIColor.clear.cgColor
        dottedLineLayer.opacity = 1.0
        dottedLineLayer.strokeColor = layoutVariables.dashedSeparatorColor.cgColor

        // Add separator layers as sublayers
        self.separatorLayers.append(dottedLineLayer)
        self.separatorLayers.append(lineLayer)
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(dottedLineLayer)
    }

    private func generateEventLayers(andResizeText resizeText: Bool = false) {
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

            guard eventsData[id] != nil else {
                return
            }
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            var newFrame = frame
            if scaleY != 1.0 || scaleX != 1.0 {
                self.eventFrames[id] = frame.applying(transform)
                newFrame = self.eventFrames[id]!
            }
            let layer = eventsData[id]!.generateLayer(withFrame: newFrame, resizeText: resizeText)

            self.eventLayers.append(layer)
            self.layer.addSublayer(layer)
        }
        if let pLayer = self.previewLayer {
            pLayer.removeFromSuperlayer()
            if previewVisible {
                self.layer.addSublayer(pLayer)
            }
        }
    }

    func longPressAction(_ sender: UILongPressGestureRecognizer) {
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

        let startingBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        let endingBounds = CGRect(x: 0, y: 0, width: self.frame.width, height: hourHeight*CGFloat(layoutVariables.previewEventHeightInHours))

        let previewLayer = CALayer()
        previewLayer.bounds = startingBounds
        previewLayer.position = position
        previewLayer.backgroundColor = layoutVariables.previewEventColor.cgColor
        previewLayer.masksToBounds = true

        let textLayer = CATextLayer()
        textLayer.frame = endingBounds
        let mainFontAttributes: [String: Any] = [NSFontAttributeName: TextVariables.eventLabelFont, NSForegroundColorAttributeName: TextVariables.eventLabelTextColor.cgColor]
        let mainAttributedString = NSMutableAttributedString(string: layoutVariables.previewEventText, attributes: mainFontAttributes)
        textLayer.string = mainAttributedString
        textLayer.isWrapped = true
        textLayer.contentsScale = UIScreen.main.scale

        previewLayer.addSublayer(textLayer)
        self.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        self.previewVisible = layoutVariables.showPreviewOnLongPress

        let anim = CABasicAnimation(keyPath: "bounds")
        anim.duration = 0.15
        anim.fromValue = previewLayer.bounds
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
            let rounded = CGFloat(Double(position.y/hourHeight).roundToNearest(layoutVariables.previewEventPrecisionInMinutes/60.0))*hourHeight
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
            let time = Double( ((prevLayer.position.y-(hourHeight*CGFloat(layoutVariables.previewEventHeightInHours/2)))/self.frame.height)*24 )
            let rounded = time.roundToNearest(layoutVariables.previewEventPrecisionInMinutes/60.0)
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

    func layoutVariables(for dayViewCell: DayViewCell) -> LayoutVariables

}
