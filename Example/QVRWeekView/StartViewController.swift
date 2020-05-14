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
        if let calendarViewController = self.tabBarController?.viewControllers?[1] as? CalendarViewController {
            calendarVC = calendarViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func customizeButtonPress(_ sender: Any) {
        if let weekView = calendarVC.weekView {
            // Day view customization
            weekView.dayViewHourIndicatorColor = UIColor.blue
            weekView.dayViewHourIndicatorThickness = 9
            weekView.dayViewCellInitialHeight = 500
            weekView.dayViewMainSeparatorColor = UIColor.red
            weekView.dayViewMainSeparatorThickness = 4
            weekView.dayViewDashedSeparatorColor = UIColor.orange
            weekView.dayViewDashedSeparatorPattern = [9, 3]
            weekView.dayViewDashedSeparatorThickness = 2

            // Day view color customization
            weekView.weekendDayViewColor = UIColor.darkGray
            weekView.defaultDayViewColor = UIColor.gray
            weekView.todayViewColor = .black
            weekView.passedDayViewColor = UIColor.green
            weekView.passedWeekendDayViewColor = UIColor.purple
            weekView.showTodayTimeOverlay = false

            // Visible days and spacing customization
            weekView.visibleDaysInPortraitMode = 3
            weekView.visibleDaysInLandscapeMode = 9
            weekView.landscapeDayViewSideSpacing = 5
            weekView.landscapeDayViewVerticalSpacing = 40
            weekView.portraitDayViewSideSpacing = 1
            weekView.portraitDayViewVerticalSpacing = 60

            // Hour label customization
            weekView.hourLabelFont = UIFont.italicSystemFont(ofSize: 5)
            weekView.hourLabelTextColor = UIColor.white
            weekView.hourLabelDateFormat = "HH:mm"

            // Regular event customization
            weekView.eventLabelTextColor = UIColor.green
            weekView.eventLabelFont = UIFont.italicSystemFont(ofSize: 25)
            weekView.eventLabelInfoFont = UIFont.boldSystemFont(ofSize: 15)
            weekView.eventLabelHorizontalTextPadding = CGFloat(0)
            weekView.eventLabelVerticalTextPadding = CGFloat(5)
            // weekView.eventLabelMinimumFontSize = 3 DEPRECATED
            // weekView.eventLabelFontResizingEnabled = false DEPRECATED
            weekView.eventStyleCallback = { (layer, data) in
                layer.borderWidth = 2.0
                layer.borderColor = UIColor.black.cgColor
            }

            // Preview event customization
            weekView.showPreviewOnLongPress = true
            weekView.previewEventText = "PREVIEW"
            weekView.previewEventColor = UIColor.black
            weekView.previewEventHeightInHours = 4
            weekView.previewEventPrecisionInMinutes = 60

            // All day event customization
            weekView.allDayEventHeight = 30
            weekView.allDayEventVerticalSpacing = 10
            weekView.allDayEventsSpreadOnX = false
            weekView.autoConvertAllDayEvents = false

            // Day-date label customization
            weekView.dayLabelTextColor = UIColor.white
            weekView.dayLabelDefaultFont = UIFont.italicSystemFont(ofSize: 20)
            weekView.dayLabelTodayTextColor = UIColor.red
            weekView.dayLabelShortDateFormat = "yy MM"
            weekView.dayLabelLongDateFormat = "y M d"
            weekView.dayLabelNormalDateFormat = "y M"
            weekView.dayLabelMinimumFontSize = 2
            weekView.dayLabelDateLocale = Locale(identifier: "nl")

            // Weekview layout customization
            weekView.mainBackgroundColor = UIColor.blue
            weekView.topBarColor = UIColor.green
            weekView.defaultTopBarHeight = 70
            weekView.sideBarColor = UIColor.green
            weekView.sideBarWidth = 40

            // Zoom and velocity customization
            weekView.minimumZoomScale = 0.1
            weekView.maximumZoomScale = 5.0
            weekView.currentZoomScale = 2.0
            weekView.velocityOffsetMultiplier = 0.01
        }
    }

    @IBAction func testButtonPress(_ sender: Any) {
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
