//
//  ViewController.swift
//  QVRWeekView
//
//  Created by reilem on 05/17/2017.
//  Copyright (c) 2017 reilem. All rights reserved.
//

import UIKit
import QVRWeekView

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

    func didLongPressDayViewCell(_ weekView: WeekView, pressedTime: Date) {
        let alert = UIAlertController(title: "Long pressed", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapEvent(_ weekView: WeekView, eventId: Int) {
        let alert = UIAlertController(title: "Tapped event", message: String(eventId), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadNewEvents(_ weekView: WeekView) {
        
    }
    
}

