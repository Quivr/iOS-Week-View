//
//  EventData.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/25/17.
//
//

import Foundation

/**
 Class event data stores basic data needed by the rest of the code to calculate and draw events in the dayViewCells in the dayScrollView.
 */
open class EventData: CustomStringConvertible, Equatable, Hashable {

    // Id of the event
    public let id: String
    // Title of the event
    public let title: String
    // Start date of the event
    public let startDate: Date
    // End date of the event
    public let endDate: Date
    // Location of the event
    public let location: String
    // Color of the event
    public let color: UIColor
    // Stores if event is an all day event
    public let allDay: Bool
    // Stores an optional gradient layer which will be used to draw event. Can only be set once.
    private(set) var gradientLayer: CAGradientLayer? { didSet { gradientLayer = oldValue ?? gradientLayer } }

    // Hashvalue
    public var hashValue: Int {
        return id.hashValue
    }

    // String descriptor
    public var description: String {
        return "[Event: {id: \(id), startDate: \(startDate), endDate: \(endDate)}]\n"
    }

    // Layer of this event
    lazy var layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        if let gradient = self.gradientLayer {
            layer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(gradient)
        }
        else {
            layer.fillColor = self.color.cgColor
        }
        let eventTextLayer = CATextLayer()
        eventTextLayer.isWrapped = true
        eventTextLayer.contentsScale = UIScreen.main.scale
        eventTextLayer.string = self.getDisplayString()
        layer.addSublayer(eventTextLayer)
        return layer
    }()

    /**
     Main initializer. All properties.
     */
    public init(id: String, title: String, startDate: Date, endDate: Date, location: String, color: UIColor, allDay: Bool) {
        self.id = id
        self.title = title
        self.location = location
        self.color = color
        self.allDay = allDay
        guard startDate.compare(endDate).rawValue <= 0 else {
            self.startDate = startDate
            self.endDate = startDate
            return
        }
        self.startDate = startDate
        self.endDate = endDate
    }

    /**
     Convenience initializer. All properties except for Int Id instead of String.
     */
    public convenience init(id: Int, title: String, startDate: Date, endDate: Date, location: String, color: UIColor, allDay: Bool) {
        self.init(id: String(id), title: title, startDate: startDate, endDate: endDate, location: location, color: color, allDay: allDay)
    }

    /**
     Convenience initializer. String Id + no allDay parameter.
     */
    public convenience init(id: String, title: String, startDate: Date, endDate: Date, location: String, color: UIColor) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, location: location, color: color, allDay: false)
    }

    /**
     Convenience initializer. Int Id + no allDay parameter.
     */
    public convenience init(id: Int, title: String, startDate: Date, endDate: Date, location: String, color: UIColor) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, location: location, color: color, allDay: false)
    }

    /**
     Convenience initializer. String Id + no allDay and location parameter.
     */
    public convenience init(id: String, title: String, startDate: Date, endDate: Date, color: UIColor) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, location: "", color: color, allDay: false)
    }

    /**
     Convenience initializer. Int Id + no allDay and location parameter.
     */
    public convenience init(id: Int, title: String, startDate: Date, endDate: Date, color: UIColor) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, location: "", color: color, allDay: false)
    }

    /**
     Convenience initializer.
     */
    public convenience init() {
        self.init(id: -1, title: "null", startDate: Date(), endDate: Date().addingTimeInterval(TimeInterval(exactly: 10000)!), color: UIColor.blue)
    }

    // Static equal comparison operator
    public static func == (lhs: EventData, rhs: EventData) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.startDate == rhs.startDate) &&
            (lhs.endDate == rhs.endDate) &&
            (lhs.title == rhs.title) &&
            (lhs.location == rhs.location) &&
            (lhs.allDay && rhs.allDay)
    }

    /**
     Returns the string that will be displayed by this event. Overridable.
     */
    open func getDisplayString(withMainFont mainFont: UIFont = FontVariables.eventLabelFont, andInfoFont infoFont: UIFont = FontVariables.eventLabelInfoFont) -> NSAttributedString {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let mainFontAttributes: [String: Any] = [NSFontAttributeName: mainFont, NSForegroundColorAttributeName: FontVariables.eventLabelTextColor.cgColor]
        let infoFontAttributes: [String: Any] = [NSFontAttributeName: infoFont, NSForegroundColorAttributeName: FontVariables.eventLabelTextColor.cgColor]
        let mainAttributedString = NSMutableAttributedString(string: self.title, attributes: mainFontAttributes)
        if !self.allDay {
            mainAttributedString.append(NSMutableAttributedString(
                string: " (\(df.string(from: self.startDate)) - \(df.string(from: self.endDate)))",
                attributes: infoFontAttributes))
        }
        if self.location != "" {
            mainAttributedString.append(NSMutableAttributedString(string: " | \(self.location)", attributes: infoFontAttributes))
        }
        return mainAttributedString

    }

    // Configures the gradient based on the provided color and given endColor.
    public func configureGradient(_ endColor: UIColor) {
        let gradient = CAGradientLayer()
        gradient.colors = [self.color.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        self.gradientLayer = gradient
    }

    // Configures the gradient based on provided gradient.
    public func configureGradient(_ gradient: CAGradientLayer?) {
        self.gradientLayer = gradient
    }

    /**
     Creates a layer object for current event data and given frame.
     */
    func generateLayer(withFrame frame: CGRect, resizeText: Bool = false) -> CAShapeLayer {

        self.layer.path = CGPath(rect: frame, transform: nil)
        for sub in self.layer.sublayers! {

            if let gradient = sub as? CAGradientLayer {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                gradient.frame = frame
                CATransaction.commit()
            }
            else if let text = sub as? CATextLayer {
                if resizeText {
                    CATransaction.setDisableActions(false)
                    if let string = text.string as? NSAttributedString {
                        let font = FontVariables.eventLabelFont
                        var fontSize = font.pointSize
                        while Util.getSize(ofString: string.string, withFont: font.withSize(fontSize), inFrame: frame).height > frame.height &&
                            fontSize > FontVariables.eventLabelMinimumFontSize {
                                fontSize -= 1
                        }
                        text.string = self.getDisplayString(
                            withMainFont: FontVariables.eventLabelFont.withSize(fontSize),
                            andInfoFont: FontVariables.eventLabelInfoFont.withSize(fontSize))
                    }
                }
                CATransaction.setDisableActions(true)
                text.frame = frame
            }

        }

        return self.layer
    }

    /**
     In case this event spans multiple days this function will be called to split it into multiple events
     which can be assigned to individual dayViewCells.
     */
    func checkForSplitting () -> [DayDate:EventData] {
        var splitEvents: [DayDate: EventData] = [:]
        let startDayDate = DayDate(date: startDate)
        if startDate.isSameDayAs(endDate) {
            splitEvents[startDayDate] = self
        }
        else if !startDate.isSameDayAs(endDate) && endDate.isMidnight(afterDate: startDate) {
            splitEvents[startDayDate] = self.remakeEventData(withStart: startDate, andEnd: endDate.addingTimeInterval(-1))
        }
        else if !endDate.isMidnight(afterDate: startDate) {
            let dateRange = DateSupport.getAllDates(between: startDate, and: endDate)
            for date in dateRange {
                if self.allDay {
                    splitEvents[DayDate(date: date)] = self.remakeEventDataAsAllDay(forDate: date)
                }
                else {
                    if date.isSameDayAs(startDate) {
                        splitEvents[DayDate(date: date)] = self.remakeEventData(withStart: startDate, andEnd: date.getEndOfDay())
                    }
                    else if date.isSameDayAs(endDate) {
                        splitEvents[DayDate(date: date)] = self.remakeEventData(withStart: date.getStartOfDay(), andEnd: endDate)
                    }
                    else {
                        splitEvents[DayDate(date: date)] = self.remakeEventDataAsAllDay(forDate: date)
                    }
                }
            }
        }
        return splitEvents
    }

    func remakeEventData(withStart start: Date, andEnd end: Date) -> EventData {
        let newEvent = EventData(id: self.id, title: self.title, startDate: start, endDate: end, location: self.location, color: self.color, allDay: self.allDay)
        newEvent.configureGradient(self.gradientLayer)
        return newEvent
    }

    func remakeEventDataAsAllDay(forDate date: Date) -> EventData {
        let newEvent = EventData(id: self.id, title: self.title, startDate: date.getStartOfDay(), endDate: date.getEndOfDay(), location: self.location, color: self.color, allDay: true)
        newEvent.configureGradient(self.gradientLayer)
        return newEvent
    }
}
