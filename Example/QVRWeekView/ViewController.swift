//
//  ViewController.swift
//  QVRWeekView
//
//  Created by reilem on 05/17/2017.
//  Copyright (c) 2017 reilem. All rights reserved.
//

import UIKit
import QVRWeekView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cV = CalendarView(frame: self.view.frame)
        self.view.addSubview(cV)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

