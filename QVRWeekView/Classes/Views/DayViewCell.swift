import Foundation
import UIKit

/**
 Class of the day view columns generated and displayed within DayScrollView
 */
class DayViewCell: UICollectionViewCell {

    // Static variable stores all ids of dayviewcells
    private static var uniqueIds: [Int] = []

    // Date and event variables
    private(set) var date: DayDate = DayDate()
    private var eventsData: [Int: EventData] = [:]
    private var eventFrames: [Int: CGRect] = [:]

    // Overlay variables
    private var bottomDistancePercent = CGFloat(0)
    private var overlayView: UIView = UIView()
    private var hourIndicatorView: UIView = UIView()

    // separator shape layers
    private var separatorLayers: [CAShapeLayer] = []
    // Event rectangle shape layers
    private var eventLayers: [CALayer] = []
    // Previous height
    private var lastResizeHeight: CGFloat!
    // Previous width
    private var lastResizeWidth: CGFloat!

    // Delegate variable
    weak var delegate: DayViewCellDelegate?
    let id: Int

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
            self.bottomDistancePercent = DateSupport.getPercentTodayPassed()
            self.backgroundColor = date.isWeekend() ? LayoutVariables.weekendDayViewColor : LayoutVariables.defaultDayViewColor
        }
        else {
            self.overlayView.isHidden = true
            if date.hasPassed() {
                self.backgroundColor = date.isWeekend() ? LayoutVariables.passedWeekendDayViewColor : LayoutVariables.passedDayViewColor
            }
            else {
                self.backgroundColor = date.isWeekend() ? LayoutVariables.weekendDayViewColor : LayoutVariables.defaultDayViewColor
            }
        }
        updateOverlay()
    }

    func setEventsData(_ eventsData: [Int: EventData], andFrames eventFrames: [Int: CGRect]) {
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
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func longPressAction(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began {

            let yTouch = sender.location(ofTouch: 0, in: self).y
            let time = Double((yTouch/self.frame.height)*24)
            let hours = Int(time)
            let minutes = Int((time-Double(hours))*60)
            self.delegate?.dayViewCellWasLongPressed(self, hours: hours, minutes: minutes)
        }
    }

    func tapAction(_ sender: UITapGestureRecognizer) {

        let tapPoint = sender.location(in: self)

        for (id, frame) in eventFrames {
            if frame.contains(tapPoint) {
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
            overlayView.backgroundColor = date.isWeekend() ? LayoutVariables.passedWeekendDayViewColor : LayoutVariables.passedDayViewColor
            hourIndicatorView.frame = CGRect(x: 0,
                                             y: overlayView.frame.height-LayoutVariables.hourIndicatorThickness/2,
                                             width: self.bounds.width,
                                             height: LayoutVariables.hourIndicatorThickness)
            hourIndicatorView.backgroundColor = LayoutVariables.hourIndicatorColor
        }

    }

    private func generateSeparatorLayers() {
        // Clear old separators
        for layer in self.separatorLayers {
            layer.removeFromSuperlayer()
        }
        self.separatorLayers.removeAll()

        let hourHeight = self.bounds.height/DateSupport.hoursInDay
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
        lineLayer.lineWidth = LayoutVariables.mainSeparatorThickness
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = LayoutVariables.mainSeparatorColor.cgColor

        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.path=dottedPathCombine
        dottedLineLayer.lineDashPattern = LayoutVariables.dashedSeparatorPattern
        dottedLineLayer.lineWidth = LayoutVariables.dashedSeparatorThickness
        dottedLineLayer.fillColor = UIColor.clear.cgColor
        dottedLineLayer.opacity = 1.0
        dottedLineLayer.strokeColor = LayoutVariables.dashedSeparatorColor.cgColor

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

            guard eventsData[id] != nil else {
                return
            }
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            var newFrame = frame
            if scaleY != 1.0 || scaleX != 1.0 {
                self.eventFrames[id] = frame.applying(transform)
                newFrame = self.eventFrames[id]!
            }

            let eventRectLayer = CAShapeLayer()
            eventRectLayer.path = CGPath(rect: newFrame, transform: nil)
            eventRectLayer.fillColor = eventsData[id]!.color.cgColor

            let eventTextLayer = CATextLayer()
            eventTextLayer.frame = newFrame
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
