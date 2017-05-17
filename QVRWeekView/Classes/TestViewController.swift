//
//  TestViewController.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/9/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet var calendarView: CalendarView!
    
    private var time:Double!
    
    
    override func viewDidLoad() {
        calendarView.setDayViewSideSpacingPortrait(to: 10)
    }
    
    @IBAction func goToToday() {
        calendarView.showToday()
    }
    
}
