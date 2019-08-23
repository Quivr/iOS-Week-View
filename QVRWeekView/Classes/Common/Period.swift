//
//  Period.swift
//  Pods
//
//  Created by Reinert Lemmens on 7/26/17.
//
//

import Foundation

/**
 Period class provides a convenient way to keep track of which periods are currently
 being displayed in which periods will have to be loaded next.
 */
class Period: CustomStringConvertible {
    let startDate: DayDate
    let endDate: DayDate

    public var description: String {
        return "[\(startDate) -> \(endDate)]"
    }

    lazy var earlyMidLimit: DayDate = {
        return self.startDate.getDayDateWith(daysAdded: 7)
    }()

    lazy var lateMidLimit: DayDate = {
        return self.endDate.getDayDateWith(daysAdded: -7)
    }()

    init(startDate: DayDate, endDate: DayDate) {
        self.startDate = startDate
        self.endDate = endDate
    }

    convenience init(ofDate date: DayDate) {
        let startThisWeek = date.getDayDateMonday()
        self.init(startDate: startThisWeek.getDayDateWith(daysAdded: -1).getDayDateMonday(),
                  endDate: startThisWeek.getDayDateWith(daysAdded: 13))
    }

    func allDaysInPeriod() -> [DayDate] {
        return DateSupport.getAllDayDates(between: startDate, and: endDate)
    }
}
