//
//  Period.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/26/17.
//
//

import Foundation

struct Period: CustomStringConvertible {

    let startDate: DayDate
    let endDate: DayDate

    public var description: String {
        return "[\(startDate) -> \(endDate)]"
    }

    var nextPeriod: Period {
        return Period(ofDate: endDate.getDayDateWith(daysAdded: 1))
    }

    var previousPeriod: Period {
        return Period(ofDate: startDate.getDayDateWith(daysAdded: -1))
    }

    init(ofDate date: DayDate) {
        self.startDate = date.getDayDateMonday()
        self.endDate = startDate.getDayDateWith(daysAdded: 6)
    }

    init(startDate: DayDate, endDate: DayDate) {
        self.startDate = startDate
        self.endDate = endDate
    }

    func allDaysInPeriod() -> [DayDate] {
        let dates = DateSupport.getAllDaysBetween(startDate.dateObj, and: endDate.dateObj)
        var dayDates: [DayDate] = []
        for date in dates {
            dayDates.append(DayDate(date: date))
        }
        return dayDates
    }

}
