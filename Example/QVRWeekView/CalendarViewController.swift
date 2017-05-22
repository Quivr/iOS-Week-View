//
//  ViewController.swift
//  QVRWeekView
//
//  Created by reilem on 05/17/2017.
//  Copyright (c) 2017 reilem. All rights reserved.
//

import UIKit
import QVRWeekView

class CalendarViewController: UIViewController {

    @IBOutlet var calendarView: WeekView!
    
    @IBAction func todayButtonPress(_ sender: Any) {
        calendarView.showToday()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

