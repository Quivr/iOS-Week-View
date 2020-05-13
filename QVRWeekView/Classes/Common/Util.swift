//
//  Util.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 06/08/2017.
//

import Foundation

/**
 Util struct provides static utility methods.
 */
struct Util {

    /**
     Get the interface orientation from status bar
     */
    static var orientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    /**
     Function returns true if given event from dayDate can not be found in the given eventStore,
     or if the event found in the eventStore with same id is different (has changed)
    */
    static func isEvent(_ event: EventData, fromDay dayDate: DayDate, notInOrHasChanged eventStore: [DayDate: [String: EventData]]) -> Bool {
        return (eventStore[dayDate] == nil) || (eventStore[dayDate]![event.id] == nil) || (eventStore[dayDate]![event.id]! != event)
    }

    /**
     Function returns true if given event from dayDate can not be found in the given eventStore,
     or if the event found in the eventStore with same id is different (has changed)
     */
    static func isEvent(_ event: EventData, fromDay dayDate: DayDate, notInOrHasChanged eventStore: [DayDate: [EventData]]) -> Bool {
        return (eventStore[dayDate] == nil) || (!eventStore[dayDate]!.contains(event))
    }

    static func getSize(ofString string: String, withFont font: UIFont, inFrame frame: CGRect) -> CGRect {
        let text = NSAttributedString(string: string, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
        return text.boundingRect(with: CGSize(width: frame.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, context: nil)
    }

    static func sortedById(eventsToSort events: [EventData]) -> [EventData] {
        return events.sorted(by: Util.sortById)
    }

    static func sortedById<T>(eventsToSort events: [EventData: T]) -> [(key: EventData, value: T)] {
        return events.sorted(by: { (entry1, entry2) -> Bool in
            Util.sortById(event1: entry1.key, event2: entry2.key)
        })
    }

    static func sortById(event1: EventData, event2: EventData) -> Bool {
        return event1.id < event2.id
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
