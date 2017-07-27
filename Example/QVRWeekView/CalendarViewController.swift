//
//  ViewController.swift
//  QVRWeekView
//
//  Created by reilem on 05/17/2017.
//  Copyright (c) 2017 reilem. All rights reserved.
//

import QVRWeekView
import UIKit

class CalendarViewController: UIViewController, WeekViewDelegate {

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

    func didLongPressDayViewCell(_ weekView: WeekView, pressedDay: String) {
        let alert = UIAlertController(title: "Long pressed", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func didTapEvent(_ weekView: WeekView, eventId: Int) {
        let alert = UIAlertController(title: "Tapped event", message: String(eventId), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func loadNewEvents(_ weekView: WeekView, between startDate: Date, and endDate: Date) {

        let STRESS_TEST = false
        let dates = DateSupport.getAllDaysBetween(startDate, and: endDate)
//        let dates = [DateSupport.getDate(forDaysInFuture: 1)]
        var events: [EventData] = []

        if STRESS_TEST {
            let n = 50
            var a = 0
            for date in dates {
                let startOfDate = date.getStartOfDay()
                for i in 0...n {
                    let I = Double(i)
                    let eventDuration = 24/(Double(n)+1)
                    let eventStartOffset = Int(eventDuration*I*60.0*60.0)
                    let eventEndOffset = Int(eventDuration*(I+1)*60.0*60.0)

                    let start = dateWithInterval(eventStartOffset, fromDate: startOfDate)
                    let end = dateWithInterval(eventEndOffset, fromDate: startOfDate)

                    let title = "Test\(a)+\(i):TextTest TextTest TextTest TextTest TextTest"
                    let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)

                    let data = EventData(id: ((dates.count)*(n+1))+i, title: title, startDate: start, endDate: end, color: color)
                    events.append(data)
                }
                a += 1
            }
        }
        else {
            var a = 0
            for date in dates {
                let n = Int(drand48()*20)
                let startOfDate = date.getStartOfDay()
                for i in 0...n {
                    let I = Double(i)
                    let eventDuration = 24/(Double(n)+1)
                    let eventStartOffset = Int((eventDuration/2)*I*60.0*60.0)
                    let eventEndOffset = Int(eventDuration*(I+1)*60.0*60.0)

                    let start = dateWithInterval(eventStartOffset, fromDate: startOfDate)
                    let end = dateWithInterval(eventEndOffset, fromDate: startOfDate)

                    let title = "Test\(a)+\(i):TextTest TextTest TextTest TextTest TextTest"
                    let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)

                    let data = EventData(id: ((dates.count)*(n+1))+i, title: title, startDate: start, endDate: end, color: color)
                    events.append(data)
                }
                a += 1
            }
        }
        weekView.addAndLoadEvents(withData: events)
    }

    private func dateWithIntervalFromNow(_ interval: Int) -> Date {
        return Date(timeIntervalSinceNow: TimeInterval(exactly: interval)!)
    }

    private func dateWithInterval(_ interval: Int, fromDate date: Date) -> Date {
        return date.addingTimeInterval(TimeInterval(exactly: interval)! )
    }

}
