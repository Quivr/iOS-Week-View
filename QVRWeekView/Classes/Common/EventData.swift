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
    // Stores an optional dictionary, containing the time of the original event before splitting
    private(set) var originalTime: [String: Date]?

    // String descriptor
    public var description: String {
        return "[Event: {id: \(id), startDate: \(startDate), endDate: \(endDate)}]\n"
    }

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
    public convenience init() {
        self.init(id: -1, title: "New Event", startDate: Date(), endDate: Date().addingTimeInterval(TimeInterval(exactly: 10000)!), color: UIColor.blue)
    }

    // Static equal comparison operator
    public static func == (lhs: EventData, rhs: EventData) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.startDate == rhs.startDate) &&
            (lhs.endDate == rhs.endDate) &&
            (lhs.title == rhs.title) &&
            (lhs.location == rhs.location) &&
            (lhs.allDay == rhs.allDay) &&
            (lhs.color.isEqual(rhs.color))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /**
     Returns the string that will be displayed by this event. Overridable.
     */
    open func getDisplayString(withMainFont mainFont: UIFont = TextVariables.eventLabelFont, andInfoFont infoFont: UIFont = TextVariables.eventLabelInfoFont) -> NSAttributedString {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let mainFontAttributes: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): mainFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): TextVariables.eventLabelTextColor.cgColor]
        let infoFontAttributes: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): infoFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): TextVariables.eventLabelTextColor.cgColor]
        let mainAttributedString = NSMutableAttributedString(string: self.title, attributes: convertToOptionalNSAttributedStringKeyDictionary(mainFontAttributes))
        if !self.allDay {
            var startShow = self.startDate
            var endShow = self.endDate
            if let origin = self.originalTime, let start = origin["startDate"], let end = origin["endDate"] {
                startShow = start
                endShow = end
            }
            mainAttributedString.append(NSMutableAttributedString(
                string: " (\(df.string(from: startShow)) - \(df.string(from: endShow)))",
                attributes: convertToOptionalNSAttributedStringKeyDictionary(infoFontAttributes))
            )
        }
        if self.location != "" {
            mainAttributedString.append(NSMutableAttributedString(string: " | \(self.location)", attributes: convertToOptionalNSAttributedStringKeyDictionary(infoFontAttributes)))
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

    // Set original time dict. based on provided start and end date
    public func setOriginalTime(oldStartDate: Date, oldEndDate: Date) {
        self.originalTime = ["startDate": oldStartDate, "endDate": oldEndDate]
    }

    // Set original time dict. based on provided dict.
    public func setOriginalTime(originTime: [String: Date]) {
        self.originalTime = originTime
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
     which can be assigned to individual dayViewCells.
     */
    func checkForSplitting () -> [DayDate: EventData] {
        var splitEvents: [DayDate: EventData] = [:]
        let startDayDate = DayDate(date: startDate)
        if startDate.isSameDayAs(endDate) {
            // Case: regular event that starts and ends in same day
            splitEvents[startDayDate] = self
        }
        else if !startDate.isSameDayAs(endDate) && endDate.isMidnight(afterDate: startDate) {
            // Case: an event that goes from to 00:00 the next day. Gets recreated to end with 23:59:59.
            let newData = self.remakeEventData(withStart: startDate, andEnd: startDate.getEndOfDay())
            newData.setOriginalTime(oldStartDate: startDate, oldEndDate: endDate)
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
                        if LayoutVariables.autoConvertAllDayEvents {
                            newData = self.remakeEventDataAsAllDay(forDate: date)
                        } else {
                            newData = self.remakeEventData(withStart: date.getStartOfDay(), andEnd: date.getEndOfDay())
                        }
                    }
                    newData.setOriginalTime(oldStartDate: self.startDate, oldEndDate: self.endDate)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
