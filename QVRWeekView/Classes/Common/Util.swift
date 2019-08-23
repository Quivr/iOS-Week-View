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
    // Function returns a dayLabel UILabel with the correct size and position according to given indexPath.
    static func makeDayLabel(withIndexPath indexPath: IndexPath) -> UILabel {
        // Make as daylabel
        let labelFrame = Util.generateDayLabelFrame(forIndex: indexPath)
        let dayLabel = UILabel(frame: labelFrame)
        dayLabel.textAlignment = .center
        return dayLabel
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

    // Function generates a frame for a day label with given index path.
    static func generateDayLabelFrame(forIndex indexPath: IndexPath) -> CGRect {
        let row = CGFloat(indexPath.row)
        return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth), y: 0, width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.defaultTopBarHeight)
    }

    /**
     Function will analyse the valid strings given from the dayDate object and determines which string will fit into the given
     label. Function will also check for font resizing if neccessary and will return the new font size if it is different to the
     current font size.
     */
    static func assignTextAndResizeFont(forLabel label: UILabel, andDate dayDate: DayDate) -> CGFloat? {
        let currentFont = label.font!
        let labelWidth = label.frame.width
        var possibleText = dayDate.getString(forMode: TextVariables.dayLabelTextMode) as NSString
        var textSize = possibleText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): currentFont]))

        label.text = possibleText as String
        if textSize.width > labelWidth && TextVariables.dayLabelTextMode != .small {
            possibleText = dayDate.defaultString as NSString
            textSize = possibleText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): currentFont]))
            if textSize.width <= labelWidth {
                label.text = possibleText as String
                TextVariables.dayLabelTextMode = .normal
            }
            else {
                let scale = (labelWidth / textSize.width)
                var newFont = currentFont.withSize(floor(currentFont.pointSize*scale))

                while possibleText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): newFont])).width > labelWidth && newFont.pointSize > TextVariables.dayLabelMinimumFontSize {
                    newFont = newFont.withSize(newFont.pointSize-0.25)
                }

                if newFont.pointSize < TextVariables.dayLabelMinimumFontSize {
                    newFont = newFont.withSize(TextVariables.dayLabelMinimumFontSize)
                }

                label.font = newFont
                if possibleText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): newFont])).width > labelWidth {
                    label.text = dayDate.smallString
                    TextVariables.dayLabelTextMode = .small
                }
                else {
                    label.text = possibleText as String
                    TextVariables.dayLabelTextMode = .normal
                }

                if newFont.pointSize < TextVariables.dayLabelCurrentFont.pointSize {
                    label.font = newFont
                    return newFont.pointSize
                }
            }
        }
        return nil
    }

    // Method resets the day label text mode back to zero.
    static func resetDayLabelTextMode() {
        TextVariables.dayLabelTextMode = .large
    }

    /**
     Functions generates a frame for an all day event according to the indexPath and
     the count (= how many'th all day event frame in current day) and the max (= how many all day events in current day.
     Depending on LayoutVariables.allDayEventsSpreadOnX, events will be spreaded on x or y axis.
     */
    static func generateAllDayEventFrame(forIndex indexPath: IndexPath, at count: Int, max: Int) -> CGRect {
        if LayoutVariables.allDayEventsSpreadOnX {
            let row = CGFloat(indexPath.row)
            let width = LayoutVariables.dayViewCellWidth/CGFloat(max)
            return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth)+CGFloat(count)*width,
                          y: LayoutVariables.defaultTopBarHeight+LayoutVariables.allDayEventVerticalSpacing,
                          width: width,
                          height: LayoutVariables.allDayEventHeight)

        } else {
            let row = CGFloat(indexPath.row)
            let height = LayoutVariables.allDayEventHeight/CGFloat(max)
            return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth),
                          y: LayoutVariables.defaultTopBarHeight+CGFloat(count)*height,
                          width: LayoutVariables.dayViewCellWidth,
                          height: height)
        }
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

// Util extension for FontVariables.
extension TextVariables {

    // Day label text mode determines which format the day labels will be displayed in. 0 is the longest, 1 is smaller, 2 is smallest format.
    fileprivate(set) static var dayLabelTextMode: TextMode = .large

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
