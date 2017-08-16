//
//  Util.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 06/08/2017.
//

import Foundation

struct Util {

    static func makeEventLayer(withData data: EventData, andFrame frame: CGRect) -> CAShapeLayer {

        let eventRectLayer = CAShapeLayer()
        eventRectLayer.path = CGPath(rect: frame, transform: nil)
        if let gradient = data.gradientLayer {
            gradient.frame = frame
            eventRectLayer.fillColor = UIColor.clear.cgColor
            eventRectLayer.addSublayer(gradient)
        }
        else {
            eventRectLayer.fillColor = data.color.cgColor
        }

        let eventTextLayer = CATextLayer()
        eventTextLayer.frame = frame
        eventTextLayer.string = data.title
        let font = FontVariables.eventLabelFont
        let ctFont: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        eventTextLayer.font = ctFont
        eventTextLayer.fontSize = font.pointSize
        eventTextLayer.isWrapped = true
        eventTextLayer.contentsScale = UIScreen.main.scale

        eventRectLayer.addSublayer(eventTextLayer)
        return eventRectLayer
    }

    static func makeDayLabel(withIndexPath indexPath: IndexPath) -> UILabel {

        // Make as daylabel
        let labelFrame = Util.generateDayLabelFrame(forIndex: indexPath)
        let dayLabel = UILabel(frame: labelFrame)
        dayLabel.font = FontVariables.dayLabelFont
        dayLabel.textColor = FontVariables.dayLabelTextColor
        dayLabel.textAlignment = .center
        return dayLabel
    }

    static func isEvent(_ event: EventData, fromDay dayDate: DayDate, notInOrHasChanged eventStore: [DayDate: [String: EventData]]) -> Bool {
        return (eventStore[dayDate] == nil) || (eventStore[dayDate]![event.id] == nil) || (eventStore[dayDate]![event.id]! != event)
    }

    static func isEvent(_ event: EventData, fromDay dayDate: DayDate, notInOrHasChanged eventStore: [DayDate: [EventData]]) -> Bool {
        return (eventStore[dayDate] == nil) || (!eventStore[dayDate]!.contains(event))
    }

    static func generateDayLabelFrame(forIndex indexPath: IndexPath) -> CGRect {
        let row = CGFloat(indexPath.row)
        return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth), y: 0, width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.defaultTopBarHeight)
    }

    static func generateDayLabelText(forLabel label: UILabel, andDate dayDate: DayDate) -> String {
        let possibleText = dayDate.simpleStringYear as NSString
        let size = possibleText.size(attributes: [NSFontAttributeName: label.font])
        if FontVariables.dayLabelShowYear && size.width <= label.frame.width {
            return dayDate.simpleStringYear
        }
        else {
            return  dayDate.simpleString
        }
    }

    static func generateAllDayEventFrame(forIndex indexPath: IndexPath, at count: Int, max: Int) -> CGRect {
        let row = CGFloat(indexPath.row)
        let width = LayoutVariables.dayViewCellWidth/CGFloat(max)
        return CGRect(x: row*(LayoutVariables.totalDayViewCellWidth)+CGFloat(count)*width,
                      y: LayoutVariables.defaultTopBarHeight+LayoutVariables.allDayEventVerticalSpacing,
                      width: width,
                      height: LayoutVariables.allDayEventHeight)
    }
}
