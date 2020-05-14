//  swiftlint:disable force_cast
//  EventDataArray.swift
//  Pods
//
//  Created by Reinert Lemmens on 14/05/2020.
//

import Foundation

open class EventDataArray: NSObject, NSCoding {

    public let eventsData: [EventData]

    public init(eventsData: [EventData]) {
        self.eventsData = eventsData
        super.init()
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.eventsData, forKey: EventDataArrayEncoderKey.eventsData)
    }

    required public convenience init?(coder: NSCoder) {
       let eventsData = coder.decodeObject(forKey: EventDataArrayEncoderKey.eventsData) as! [EventData]
       self.init(eventsData: eventsData)
    }
}

struct EventDataArrayEncoderKey {
    static let eventsData = "EVENT_DATA_ARRAY_EVENTS_DATA"
}
