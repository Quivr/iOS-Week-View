# QVRWeekView

[![CI Status](http://img.shields.io/travis/reilem/QVRWeekView.svg?style=flat)](https://travis-ci.org/reilem/QVRWeekView)
[![Version](https://img.shields.io/cocoapods/v/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)
[![License](https://img.shields.io/cocoapods/l/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)
[![Platform](https://img.shields.io/cocoapods/p/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)

## About

[WIP] QVRWeekView is a framework that contains a week/day view that will soon also allow you to display, add and remove events.

## Features

* Horizontal and vertical scrolling
* Infinite horizontal scrolling
* Zooming
* Colour, size and font customization features

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This pod requires a minimum deployment target of iOS 9.0.

## Installation

QVRWeekView is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "QVRWeekView"
```

## Usage

Once the framework is installed, there are two ways you can incorporate the WeekView into your project:

#### 1. Programatically

To add the WeekView programatically, simply import QVRWeekView into your code by adding:
```ruby
import QVRWeekView
```
at the top of your source file containing your view controller.
Then insert the WeekView into your view controller by adding:
```ruby
let weekView = WeekView(frame: self.view.frame)
self.view.addSubview(weekView)
```
into either your viewDidLoad or viewWillAppear method.

#### 2. Via the storyboard

To add the WeekView via the storyboard, simply add a View onto your View Controller and resize it or add constraints. Then go to the identity inspector of your view and select the Class to be `WeekView` and the module to be `QVRWeekView` (See image).

![image](http://i.imgur.com/5ymQ8iE.png "Identity Inspector - WeekView")

Then you should be all set!

### Extra notes

For now the only methods publicly available are some customization functions, and a few useful features such as "show today" and "update time". Remember, WeekView is a subclass of UIView and can be used as such.

## How it works

The main WeekView view is a subclass of UIView. The view layout is retrieved from the WeekView xib file. WeekView contains a top and side bar sub view. The side bar contains an HourSideBarView which displays the hours. WeekView also contains a DayScrollView (UIScrollView subclass) which controls vertical scrolling and also delegates and contans a DayCollectionView (UICollectionView subclass) which controls the horizontal scrolling. DayCollectionView cells are DayViewCells, whose view is generated programtically (due to inefficiencies caused by auto-layout).

WeekView handles top level operations such as pinch gestures and orientation change. Scrolling of the top and side bar is also handled by a function inside of WeekView which is called by the DayScrollView when scrolling. Top bar day labels are generated, displayed and discarded simulaneously with DayCollectionView cells.

## Upcoming features

* Ability to add and remove events
* Event color customization
* Extra customization features

## Author

Reinert Lemmens, reilemx@gmail.com

## License

QVRWeekView is available under the MIT license. See the LICENSE file for more info.
