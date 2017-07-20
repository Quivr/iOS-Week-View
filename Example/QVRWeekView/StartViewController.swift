//
//  StartViewController.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 5/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    var calendarVC: CalendarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarVC = self.tabBarController?.viewControllers?[1] as! CalendarViewController
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func customizeButtonPress(_ sender: Any) {
        if let weekView = calendarVC.weekView {        
            weekView.dayViewHourIndicatorColor = UIColor.blue
            weekView.dayViewHourIndicatorThickness = 9
            weekView.dayViewOverlayColor = UIColor.brown
            weekView.dayViewCellHeight = 500
            weekView.dayViewMainSeperatorColor = UIColor.red
            weekView.dayViewMainSeperatorThickness = 4
            weekView.dayViewDashedSeperatorColor = UIColor.orange
            weekView.dayViewDashedSeperatorPattern = [9,3]
            weekView.dayViewDashedSeperatorThickness = 2
            weekView.weekendDayViewColor = UIColor.darkGray
            weekView.defaultDayViewColor = UIColor.gray
            
            weekView.visibleDaysInPortraitMode = 3
            weekView.visibleDaysInLandscapeMode = 9
            weekView.landscapeDayViewSideSpacing = 5
            weekView.landscapeDayViewVerticalSpacing = 40
            weekView.portraitDayViewSideSpacing = 1
            weekView.portraitDayViewVerticalSpacing = 60
            
            weekView.hourLabelFont = UIFont.italicSystemFont(ofSize: 5)
            weekView.hourLabelTextColor = UIColor.blue
            
            weekView.eventLabelMinimumScale = 0.05
            weekView.eventLabelTextColor = UIColor.green
            weekView.eventLabelFont = UIFont.italicSystemFont(ofSize: 25)
            
            weekView.dayLabelTextColor = UIColor.white
            weekView.dayLabelFont = UIFont.italicSystemFont(ofSize: 20)
            
            weekView.topBarColor = UIColor.green
            weekView.topBarHeight = 50
            weekView.sideBarColor = UIColor.orange
            weekView.sideBarWidth = 10
            weekView.mainBackgroundColor = UIColor.blue
            
            weekView.velocityOffsetMultiplier = 0.01
        }
    }

    @IBAction func testButtonPress(_ sender: Any) {
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         print("segue")
    }
    
}
