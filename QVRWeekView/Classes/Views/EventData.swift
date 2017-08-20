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
    // Stores an optional gradient layer which will be used to draw event.
    private(set) var gradientLayer: CAGradientLayer?

    // Hashvalue
    public var hashValue: Int {
        return id.hashValue
    }

    // Stirng descriptor
    public var description: String {
        return "[Event: {id: \(id), startDate: \(startDate), endDate: \(endDate)}]\n"
    }

    /**
     Main initializer. All properties.
     */
    public init(id: String, title: String, startDate: Date, endDate: Date, location: String, color: UIColor, allDay: Bool) {
        self.id = id
        self.title = title
        if startDate.compare(endDate).rawValue >= 0 {
            fatalError("Invalid start and end date passed to EventData on initialisation. Start: \(startDate), End: \(endDate)")
        }
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.color = color
        self.allDay = allDay
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
        return (lhs.id == rhs.id) && (lhs.startDate == rhs.startDate) && (lhs.endDate == rhs.endDate) && (lhs.title == rhs.title)
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
    public func configureGradient(_ gradient: CAGradientLayer) {
        self.gradientLayer = gradient
    }

    /**
     Creates a layer object for current event data and given frame.
     */
    func generateLayer(withFrame frame: CGRect) -> CAShapeLayer {
        let eventRectLayer = CAShapeLayer()
        eventRectLayer.path = CGPath(rect: frame, transform: nil)
        if let gradient = self.gradientLayer {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            gradient.frame = frame
            CATransaction.commit()
            eventRectLayer.fillColor = UIColor.clear.cgColor
            eventRectLayer.addSublayer(gradient)
        }
        else {
            eventRectLayer.fillColor = self.color.cgColor
        }

        let string = self.getEventDisplayString()
        let eventTextLayer = CATextLayer()
        eventTextLayer.frame = frame
        eventTextLayer.string = string
        let font = FontVariables.eventLabelFont

//        let attributedTitle = NSAttributedString(string: string, attributes: [NSFontAttributeName: font])
//        let titleSize = attributedTitle.boundingRect(with: CGSize(width: frame.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, context: nil)
        let ctFont: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)

        eventTextLayer.font = ctFont
        eventTextLayer.fontSize = font.pointSize
        eventTextLayer.isWrapped = true
        eventTextLayer.truncationMode = kCATruncationEnd
        eventTextLayer.contentsScale = UIScreen.main.scale

        eventRectLayer.addSublayer(eventTextLayer)
        return eventRectLayer
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
        return EventData(id: self.id, title: self.title, startDate: start, endDate: end, location: self.location, color: self.color, allDay: self.allDay)
    }

    func remakeEventDataAsAllDay(forDate date: Date) -> EventData {
        return EventData(id: self.id, title: self.title, startDate: date.getStartOfDay(), endDate: date.getEndOfDay(), location: self.location, color: self.color, allDay: true)
    }

    private func getEventDisplayString() -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let timeStr = self.allDay ? "" : " (\(df.string(from: self.startDate)) - \(df.string(from: self.endDate)))"
        return "\(self.title)\(timeStr) \(self.location != "" ? "| \(self.location)" : "")"

    }
}
