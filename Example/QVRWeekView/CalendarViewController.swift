//
//  ViewController.swift
//  QVRWeekView
//
//  Created by reilem on 05/17/2017.
//  Copyright (c) 2017 reilem. All rights reserved.
//

import QVRWeekView
import UIKit

public var autoFillEvents = false

class CalendarViewController: UIViewController, WeekViewDelegate {

    var allEvents: [Int: EventData] = [:]
    var eventsSortedByDay: [Date: [EventData]] = [:]
    var id: Int = 0

    @IBOutlet var weekView: WeekView!

    @IBAction func todayButtonPress(_ sender: Any) {
        weekView.showToday()
    }

    @IBAction func testButtonPress(_ sender: Any) {
        weekView.loadEvents(withData: [])
    }

    @IBAction func loadButtonPress(_ sender: Any) {
        self.fetchEvents()
    }

    @IBAction func saveButtonPress(_ sender: Any) {
        self.saveEvents()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        weekView.zoomOffsetPreservation = .reset
        weekView.delegate = self
        weekView.eventStyleCallback = { (layer, data) in
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.black.cgColor
            layer.cornerRadius = 5.0
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        weekView.currentZoomScale = 0.75
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didLongPressDayView(in weekView: WeekView, atDate date: Date) {
        let alert = UIAlertController(title: "Long pressed \(date.description(with: Locale.current))",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Short Gradient", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(id: self.id,
                                     title: "Test Event \(self.id)",
                                     startDate: date,
                                     endDate: date.addingTimeInterval(60*60*1),
                                     location: "loc test",
                                     color: color)
            newEvent.configureGradient(UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5))
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Short", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(id: self.id,
                                     title: "Test Event \(self.id)",
                                     startDate: date,
                                     endDate: date.addingTimeInterval(60*60*1),
                                     location: "loc test",
                                     color: color)
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Medium", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(id: self.id,
                                     title: "Test Event \(self.id)",
                                     startDate: date,
                                     endDate: date.addingTimeInterval(60*60*3),
                                     location: "loc test",
                                     color: color)
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Long", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(id: self.id,
                                     title: "Test Event \(self.id)",
                                     startDate: date,
                                     endDate: date.addingTimeInterval(60*60*4),
                                     location: "loc test",
                                     color: color)
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Very long", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(
                id: self.id,
                title: "Test Event \(self.id)",
                startDate: date,
                endDate: date.addingTimeInterval(60*60*24*3),
                location: "loc test",
                color: color
            )
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Single all day", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(
                id: self.id,
                title: "Test Event \(self.id)",
                startDate: date.getStartOfDay(),
                endDate: date.getEndOfDay(),
                location: "loc test",
                color: color,
                allDay: true
            )
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Multi all day", style: .default, handler: { _ in
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            let newEvent = EventData(
                id: self.id,
                title: "Test Event \(self.id)",
                startDate: date.getStartOfDay(),
                endDate: date.addingTimeInterval(60*60*24*2.5),
                location: "loc test",
                color: color,
                allDay: true
            )
            self.allEvents[self.id] = newEvent
            self.id += 1
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            weekView.redrawEvents()
        }))

        self.present(alert, animated: true, completion: nil)

    }

    func didTapEvent(in weekView: WeekView, withId eventId: String) {
        let alert = UIAlertController(title: "Tapped event", message: "\(eventId)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Change color", style: .default, handler: { (_) in
            let id = Int(eventId)!
            let event = self.allEvents[id]!
            let newEvent = event.remakeEventData(withColor: UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5))
            self.allEvents[id] = newEvent
            weekView.loadEvents(withData: Array(self.allEvents.values))
        }))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (_) -> Void in
            self.allEvents[Int(eventId)!] = nil
            self.eventsSortedByDay.removeAll()
            for event in Array(self.allEvents.values) {
                let date = event.startDate.getDayValue()
                if self.eventsSortedByDay[date] == nil {
                    self.eventsSortedByDay[date] = [event]
                }
                else {
                    self.eventsSortedByDay[date]?.append(event)
                }
            }

            weekView.loadEvents(withData: Array(self.allEvents.values))

        }))
        self.present(alert, animated: true, completion: nil)
    }

    func eventLoadRequest(in weekView: WeekView, between startDate: Date, and endDate: Date) {

        let dates = DateSupport.getAllDates(between: startDate, and: endDate)

        for (date, events) in eventsSortedByDay where !dates.contains(date) {
            for event in events {
                allEvents[Int(event.id)!] = nil
            }
            eventsSortedByDay[date] = nil
        }

        if autoFillEvents {
            for date in dates where eventsSortedByDay[date] == nil {
                var dateEvents: [EventData] = []
                let n = Int(drand48()*25)
                let startOfDate = date.getStartOfDay()
                for _ in 0...n {
                    let hourDuration = Double(Int(drand48()*4)+1)
                    let hourStart = drand48()*21
                    let eventStartOffset = Int((hourStart)*60.0*60.0)
                    let eventEndOffset = eventStartOffset+Int(hourDuration*60.0*60.0)

                    let start = dateWithInterval(eventStartOffset, fromDate: startOfDate)
                    let end = dateWithInterval(eventEndOffset, fromDate: startOfDate)

                    let title = "Test+\(id):TextTest TextTest TextTest TextTest TextTest"
                    let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)

                    let data = EventData(id: id, title: title, startDate: start, endDate: end, color: color)
                    allEvents[id] = data
                    dateEvents.append(data)
                    id += 1
                }
                eventsSortedByDay[date] = dateEvents
            }
        }
        weekView.loadEvents(withData: allEvents.isEmpty ? nil : Array(allEvents.values))
    }

    func didEndZooming(in weekView: WeekView, scale zoomScale: CGFloat) {
        // OPTIONAL
    }

    func activeDayChanged(in weekView: WeekView, to date: Date) {
        // OPTIONAL
    }

    func didEndVerticalScrolling(in weekView: WeekView, top topOffset: Double, bottom bottomOffset: Double) {
        // OPTIONAL
    }

    private func dateWithIntervalFromNow(_ interval: Int) -> Date {
        return Date(timeIntervalSinceNow: TimeInterval(exactly: interval)!)
    }

    private func dateWithInterval(_ interval: Int, fromDate date: Date) -> Date {
        return date.addingTimeInterval(TimeInterval(exactly: interval)! )
    }

    func saveEvents() {
        EventStorage.storeEvents(events: Array(allEvents.values))
    }

    func fetchEvents() {
        self.weekView.loadEvents(withData: EventStorage.getEvents())
    }

    func deleteEvents() {
        EventStorage.deleteEvents()
    }
}
