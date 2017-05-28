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
            weekView.setDayViewHourIndicatorColor(to: UIColor.blue)
            weekView.setDayViewHourIndicatorThickness(to: 9)
            weekView.setDayViewOverlayColor(to: UIColor.brown)
            weekView.setDayViewCellHeight(to: 500)
            weekView.setDayViewMainSeperatorColor(to: UIColor.red)
            weekView.setDayViewMainSeperatorThickness(to: 4)
            weekView.setDayViewDashedSeperatorColor(to: UIColor.orange)
            weekView.setDayViewDashedSeperatorPattern(to: [9,3])
            weekView.setDayViewDashedSeperatorThickness(to: 2)
            weekView.setWeekendDayViewColor(to: UIColor.darkGray)
            weekView.setDefaultDayViewColor(to: UIColor.gray)
            
            weekView.setVisibleDaysPortrait(numberOfDays: 3)
            weekView.setVisibleDaysLandscape(numberOfDays: 9)
            weekView.setLandscapeDayViewSideSpacing(to: 5)
            weekView.setLandscapeDayViewVerticalSpacing(to: 40)
            weekView.setPortraitDayViewSideSpacing(to: 1)
            weekView.setPortraitDayViewVerticalSpacing(to: 60)
            
            weekView.setHourLabelFont(to: UIFont.italicSystemFont(ofSize: 5))
            weekView.setHourLabelTextColor(to: UIColor.blue)
            
            weekView.setEventLabelMinimumScale(to: 0.05)
            weekView.setEventLabelTextColor(to: UIColor.green)
            weekView.setEventLabelFont(to: UIFont.italicSystemFont(ofSize: 25))
            
            weekView.setDayLabelTextColor(to: UIColor.white)
            weekView.setDayLabelFont(to: UIFont.italicSystemFont(ofSize: 20))
            
            weekView.setTopBarColor(to: UIColor.green)
            weekView.setTopBarHeight(to: 50)
            weekView.setSideBarColor(to: UIColor.orange)
            weekView.setSideBarWidth(to: 10)
            weekView.setBackgroundColor(to: UIColor.blue)
            
            weekView.setVelocityOffsetMultiplier(to: 0.01)
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         print("segue")
    }
    
}
