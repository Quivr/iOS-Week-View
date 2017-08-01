//
//  ViewController.swift
//  QVRWeekView
//
//  Created by reilem on 05/17/2017.
//  Copyright (c) 2017 reilem. All rights reserved.
//

import QVRWeekView
import UIKit

public var autoFillEvents = true

class CalendarViewController: UIViewController, WeekViewDelegate {

    var allEvents: [Int: EventData] = [:]
    var eventsSortedByDay: [Date: [EventData]] = [:]
    var id: Int = 0

    @IBOutlet var weekView: WeekView!

    @IBAction func todayButtonPress(_ sender: Any) {
        weekView.showToday()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        weekView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didLongPressDayView(in weekView: WeekView, atDate date: Date) {
        let alert = UIAlertController(title: "Long pressed \(date.description(with: Locale.current))",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
        let newEvent = EventData(id: id,
                                 title: "Test Event \(id)",
                                 startDate: date,
                                 endDate: date.addingTimeInterval(60*60*2),
                                 color: color)
        allEvents[id] = newEvent
        id += 1
        weekView.appendEvents(withData: [newEvent])
    }

    func didTapEvent(in weekView: WeekView, eventId: Int) {
        let alert = UIAlertController(title: "Tapped event", message: "\(eventId)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (_) -> Void in
            weekView.removeEvents(withIds: [eventId])
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func loadNewEvents(in weekView: WeekView, between startDate: Date, and endDate: Date) {

        let dates = DateSupport.getAllDaysBetween(startDate, and: endDate)
        var events: [EventData] = []
        var a = 0
        if autoFillEvents {
            for date in dates {
                if eventsSortedByDay[date] == nil {
                    var dateEvents: [EventData] = []
                    let n = Int(drand48()*25)
                    let startOfDate = date.getStartOfDay()
                    for i in 0...n {
                        let hourDuration = Double(Int(drand48()*4)+1)
                        let hourStart = drand48()*21
                        let eventStartOffset = Int((hourStart)*60.0*60.0)
                        let eventEndOffset = eventStartOffset+Int(hourDuration*60.0*60.0)

                        let start = dateWithInterval(eventStartOffset, fromDate: startOfDate)
                        let end = dateWithInterval(eventEndOffset, fromDate: startOfDate)

                        let title = "Test\(a)+\(i):TextTest TextTest TextTest TextTest TextTest"
                        let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)

                        let data = EventData(id: id, title: title, startDate: start, endDate: end, color: color)
                        allEvents[id] = data
                        events.append(data)
                        dateEvents.append(data)
                        id += 1
                    }
                    eventsSortedByDay[date] = dateEvents
                }
                else {
                    events.append(contentsOf: eventsSortedByDay[date]!)
                }
                a += 1
            }
        }

//        if STRESS_TEST {
//            let n = 50
//            var a = 0
//            for date in dates {
//                let startOfDate = date.getStartOfDay()
//                for i in 0...n {
//                    let I = Double(i)
//                    let eventDuration = 24/(Double(n)+1)
//                    let eventStartOffset = Int(eventDuration*I*60.0*60.0)
//                    let eventEndOffset = Int(eventDuration*(I+1)*60.0*60.0)
//
//                    let start = dateWithInterval(eventStartOffset, fromDate: startOfDate)
//                    let end = dateWithInterval(eventEndOffset, fromDate: startOfDate)
//
//                    let title = "Test\(a)+\(i):TextTest TextTest TextTest TextTest TextTest"
//                    let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
//                    let data = EventData(id: id, title: title, startDate: start, endDate: end, color: color)
//                    allEvents[id] = data
//                    events.append(data)
//                    id += 1
//                }
//                a += 1
//            }
//        }
//        else {
//            var a = 0
//            for date in dates {
//                let n = Int(drand48()*25)
//                let startOfDate = date.getStartOfDay()
//                for i in 0...n {
//                    let I = Double(i)
//                    let eventDuration = 24/(Double(n)+1)
//                    let eventStartOffset = Int((eventDuration/2)*I*60.0*60.0)
//                    let eventEndOffset = Int(eventDuration*(I+1)*60.0*60.0)
//
//                    let start = dateWithInterval(eventStartOffset, fromDate: startOfDate)
//                    let end = dateWithInterval(eventEndOffset, fromDate: startOfDate)
//
//                    let title = "Test\(a)+\(i):TextTest TextTest TextTest TextTest TextTest"
//                    let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
//
//                    let data = EventData(id: id, title: title, startDate: start, endDate: end, color: color)
//                    allEvents[id] = data
//                    events.append(data)
//                    id += 1
//                }
//                a += 1
//            }
//        }
        weekView.overwriteAllEvents(withNewData: events)
    }

    private func dateWithIntervalFromNow(_ interval: Int) -> Date {
        return Date(timeIntervalSinceNow: TimeInterval(exactly: interval)!)
    }

    private func dateWithInterval(_ interval: Int, fromDate date: Date) -> Date {
        return date.addingTimeInterval(TimeInterval(exactly: interval)! )
    }

}
