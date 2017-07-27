//
//  EventData.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/25/17.
//
//

import Foundation

public struct EventData {

    let id: Int
    let title: String
    let startDate: Date
    let endDate: Date
    let color: UIColor

    public init(id: Int, title: String, startDate: Date, endDate: Date, color: UIColor) {
        self.id = id
        self.title = title
        if startDate.compare(endDate).rawValue == 1 {
            fatalError("Invalid start and end date passed to EventData on initialisation. Start: \(startDate), End: \(endDate)")
        }
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
    }

    public init() {
        self.init(id: 0, title: "null", startDate: Date(), endDate: Date().addingTimeInterval(TimeInterval(exactly: 10000)!), color: UIColor.blue)
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
