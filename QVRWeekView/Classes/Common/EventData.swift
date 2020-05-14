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
open class EventData: NSObject, NSCoding {
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

    // String descriptor
    override public var description: String {
        return "[Event: {id: \(id), startDate: \(startDate), endDate: \(endDate)}]\n"
    }

    /**
     Main initializer. All properties.
     */
    public init(id: String, title: String, startDate: Date, endDate: Date, location: String, color: UIColor, allDay: Bool, gradientLayer: CAGradientLayer? = nil) {
        self.id = id
        self.title = title
        self.location = location
        self.color = color
        self.allDay = allDay
        guard startDate.compare(endDate).rawValue <= 0 else {
            self.startDate = startDate
            self.endDate = startDate
            super.init()
            return
        }
        self.startDate = startDate
        self.endDate = endDate
        super.init()
        self.configureGradient(gradientLayer)
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
     Convenience initializer. Int Id + allDay and no location parameter.
     */
    public convenience init(id: Int, title: String, startDate: Date, endDate: Date, color: UIColor, allDay: Bool) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, location: "", color: color, allDay: allDay)
    }

    /**
     Convenience initializer. String Id + allDay and no location parameter.
     */
    public convenience init(id: String, title: String, startDate: Date, endDate: Date, color: UIColor, allDay: Bool) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, location: "", color: color, allDay: allDay)
    }

    /**
     Convenience initializer.
     */
    override public convenience init() {
        self.init(id: -1, title: "New Event", startDate: Date(), endDate: Date().addingTimeInterval(TimeInterval(exactly: 10000)!), color: UIColor.blue)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: EventDataEncoderKey.id)
        coder.encode(title, forKey: EventDataEncoderKey.title)
        coder.encode(startDate, forKey: EventDataEncoderKey.startDate)
        coder.encode(endDate, forKey: EventDataEncoderKey.endDate)
        coder.encode(location, forKey: EventDataEncoderKey.location)
        coder.encode(color, forKey: EventDataEncoderKey.color)
        coder.encode(allDay, forKey: EventDataEncoderKey.allDay)
        coder.encode(gradientLayer, forKey: EventDataEncoderKey.gradientLayer)
    }

    public required convenience init?(coder: NSCoder) {
        if  let dId = coder.decodeObject(forKey: EventDataEncoderKey.id) as? String,
            let dTitle = coder.decodeObject(forKey: EventDataEncoderKey.title) as? String,
            let dStartDate = coder.decodeObject(forKey: EventDataEncoderKey.startDate) as? Date,
            let dEndDate = coder.decodeObject(forKey: EventDataEncoderKey.endDate) as? Date,
            let dLocation = coder.decodeObject(forKey: EventDataEncoderKey.location) as? String,
            let dColor = coder.decodeObject(forKey: EventDataEncoderKey.color) as? UIColor {
                let dGradientLayer = coder.decodeObject(forKey: EventDataEncoderKey.gradientLayer) as? CAGradientLayer
                let dAllDay = coder.decodeBool(forKey: EventDataEncoderKey.allDay)
                self.init(id: dId,
                          title: dTitle,
                          startDate: dStartDate,
                          endDate: dEndDate,
                          location: dLocation,
                          color: dColor,
                          allDay: dAllDay,
                          gradientLayer: dGradientLayer)
        } else {
            return nil
        }
    }

    // Static equal comparison operator
    public static func isEqual(lhs: EventData, rhs: EventData) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.startDate == rhs.startDate) &&
            (lhs.endDate == rhs.endDate) &&
            (lhs.title == rhs.title) &&
            (lhs.location == rhs.location) &&
            (lhs.allDay == rhs.allDay) &&
            (lhs.color.isEqual(rhs.color))
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }

    /**
     Returns the string that will be displayed by this event. Overridable.
     */
    open func getDisplayString(withMainFont mainFont: UIFont, infoFont: UIFont, andColor color: UIColor) -> NSAttributedString {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let mainFontAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: mainFont, NSAttributedString.Key.foregroundColor: color.cgColor]
        let infoFontAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: infoFont, NSAttributedString.Key.foregroundColor: color.cgColor]
        let mainAttributedString = NSMutableAttributedString(string: self.title, attributes: mainFontAttributes)
        if !self.allDay {
            mainAttributedString.append(NSMutableAttributedString(
                string: " (\(df.string(from: self.startDate)) - \(df.string(from: self.endDate)))",
                attributes: infoFontAttributes)
            )
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

    // Configures the gradient based on provided gradient. Only preserves colors, start and endpoint.
    public func configureGradient(_ gradient: CAGradientLayer?) {
        if let grad = gradient {
            let newGrad = CAGradientLayer()
            newGrad.colors = grad.colors
            newGrad.startPoint = grad.startPoint
            newGrad.endPoint = grad.endPoint
            self.gradientLayer = newGrad
        }
    }

    public func remakeEventData(withStart start: Date, andEnd end: Date) -> EventData {
        let newEvent = EventData(id: self.id, title: self.title, startDate: start, endDate: end, location: self.location, color: self.color, allDay: self.allDay)
        newEvent.configureGradient(self.gradientLayer)
        return newEvent
    }

    public func remakeEventData(withColor color: UIColor) -> EventData {
        let newEvent = EventData(id: self.id, title: self.title, startDate: self.startDate, endDate: self.endDate, location: self.location, color: color, allDay: self.allDay)
        newEvent.configureGradient(self.gradientLayer)
        return newEvent
    }

    public func remakeEventDataAsAllDay(forDate date: Date) -> EventData {
        let newEvent = EventData(id: self.id, title: self.title, startDate: date.getStartOfDay(), endDate: date.getEndOfDay(), location: self.location, color: self.color, allDay: true)
        newEvent.configureGradient(self.gradientLayer)
        return newEvent
    }

    /**
     In case this event spans multiple days this function will be called to split it into multiple events
     which can be assigned to individual dayViewCells.b
     */
    func checkForSplitting (andAutoConvert autoConvertAllDayEvents: Bool) -> [DayDate: EventData] {
        var splitEvents: [DayDate: EventData] = [:]
        let startDayDate = DayDate(date: startDate)
        if startDate.isSameDayAs(endDate) {
            // Case: regular event that starts and ends in same day
            splitEvents[startDayDate] = self
        }
        else if !startDate.isSameDayAs(endDate) && endDate.isMidnight(afterDate: startDate) {
            // Case: an event that goes from to 00:00 the next day. Gets recreated to end with 23:59:59.
            let newData = self.remakeEventData(withStart: startDate, andEnd: startDate.getEndOfDay())
            splitEvents[startDayDate] = newData
        }
        else if !endDate.isMidnight(afterDate: startDate) {
            // Case: an event that goes across multiple days
            let dateRange = DateSupport.getAllDates(between: startDate, and: endDate)
            // Iterate over all days that the event traverses
            for date in dateRange {
                if self.allDay {
                    // If the event is an allday event remake it as all day for this day.
                    splitEvents[DayDate(date: date)] = self.remakeEventDataAsAllDay(forDate: date)
                }
                else {
                    var newData = EventData()
                    if date.isSameDayAs(startDate) {
                        // The first fragment of a split event
                        newData = self.remakeEventData(withStart: startDate, andEnd: date.getEndOfDay())
                    }
                    else if date.isSameDayAs(endDate) {
                        // The last fragment of a split event
                        newData = self.remakeEventData(withStart: date.getStartOfDay(), andEnd: endDate)
                    }
                    else {
                        // A fragment in the middle
                        if autoConvertAllDayEvents {
                            // If enabled, split the day into an all day event
                            newData = self.remakeEventDataAsAllDay(forDate: date)
                        } else {
                            // If not enabled, let the event run the full length of the day
                            newData = self.remakeEventData(withStart: date.getStartOfDay(), andEnd: date.getEndOfDay())
                        }
                    }
                    splitEvents[DayDate(date: date)] = newData
                }
            }
        }
        return splitEvents
    }

    func getGradientLayer(withFrame frame: CGRect) -> CAGradientLayer? {
        guard let gradient = self.gradientLayer else {
            return nil
        }
        let newGrad = CAGradientLayer()
        newGrad.colors = gradient.colors
        newGrad.startPoint = gradient.startPoint
        newGrad.endPoint = gradient.endPoint
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        newGrad.frame = frame
        CATransaction.commit()
        return newGrad
    }
}

struct EventDataEncoderKey {
    static let id = "EVENT_DATA_ID"
    static let title = "EVENT_DATA_TITLE"
    static let startDate = "EVENT_DATA_START_DATE"
    static let endDate = "EVENT_DATA_END_DATE"
    static let location = "EVENT_DATA_LOCATION"
    static let color = "EVENT_DATA_COLOR"
    static let allDay = "EVENT_DATA_ALL_DAY"
    static let gradientLayer = "EVENT_DATA_GRADIENT_LAYER"
}
