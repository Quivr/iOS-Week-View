//
//  Period.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/26/17.
//
//

import Foundation

class Period: CustomStringConvertible {

    let startDate: DayDate
    let endDate: DayDate

    public var description: String {
        return "[\(startDate) -> \(endDate)]"
    }

    lazy var nextPeriod: Period = {
        return Period(ofDate: self.endDate.getDayDateWith(daysAdded: 1))
    }()

    lazy var previousPeriod: Period = {
        return Period(ofDate: self.startDate.getDayDateWith(daysAdded: -1))
    }()

    lazy var surroundingPeriods: [Period] = {
        return [self.previousPeriod, self, self.nextPeriod]
    }()

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
