//
//  EventData.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/25/17.
//
//

import Foundation

public struct EventData: CustomStringConvertible, Equatable, Hashable {

    public let id: Int
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let color: UIColor
    public let allDay: Bool

    public var hashValue: Int {
        return id
    }

    public var description: String {
        return "[Event: {id: \(id), startDate: \(startDate), endDate: \(endDate)}]\n"
    }

    public init(id: Int, title: String, startDate: Date, endDate: Date, color: UIColor, allDay: Bool) {
        self.id = id
        self.title = title
        if startDate.compare(endDate).rawValue >= 0 {
            fatalError("Invalid start and end date passed to EventData on initialisation. Start: \(startDate), End: \(endDate)")
        }
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.allDay = allDay
    }

    public init(id: Int, title: String, startDate: Date, endDate: Date, color: UIColor) {
        self.init(id: id, title: title, startDate: startDate, endDate: endDate, color: color, allDay: false)
    }

    public init() {
        self.init(id: -1, title: "null", startDate: Date(), endDate: Date().addingTimeInterval(TimeInterval(exactly: 10000)!), color: UIColor.blue)
    }

    public static func == (lhs: EventData, rhs: EventData) -> Bool {
        return (lhs.id == rhs.id) && (lhs.startDate == rhs.startDate) && (lhs.endDate == rhs.endDate) && (lhs.title == rhs.title)
    }

    func split(across dateRange: [Date]) -> [Date:EventData] {

        let start = self.startDate
        let end = self.endDate

        guard dateRange.count > 1 && !start.isSameDayAs(end) else {
            return [start.getDayValue(): self]
        }

        var splitEventData: [Date:EventData] = [:]

        for date in dateRange {
            if date.isSameDayAs(start) {
                splitEventData[start.getDayValue()] = remakeEventData(withStart: start, andEnd: start.getEndOfDay())
            }
            else if date.isSameDayAs(end) {
                splitEventData[end.getDayValue()] = remakeEventData(withStart: end.getStartOfDay(), andEnd: end)
            }
            else {
                splitEventData[date.getDayValue()] = remakeEventData(withStart: date.getStartOfDay(), andEnd: date.getEndOfDay())
            }
        }

        return splitEventData
    }

    func remakeEventData(withStart start: Date, andEnd end: Date) -> EventData {
        let id = self.id
        let color = self.color
        let title = self.title

        return EventData(id: id, title: title, startDate: start, endDate: end, color: color)
    }
}
