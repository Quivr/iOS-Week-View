# QVRWeekView

[![CI Status](http://img.shields.io/travis/reilem/QVRWeekView.svg?style=flat)](https://travis-ci.org/reilem/QVRWeekView)
[![Version](https://img.shields.io/cocoapods/v/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)
[![License](https://img.shields.io/cocoapods/l/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)
[![Platform](https://img.shields.io/cocoapods/p/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)

## About

QVRWeekView is a work in progress framework that contains a week/day view that allows you to display, add and remove events.

<img src="http://i.imgur.com/z5sn14F.gif" width="200"> <img src="http://i.imgur.com/VdOGgiP.gif" width="200">

### Features

* Horizontal and vertical scrolling
* Infinite horizontal scrolling
* Zooming
* Colour, size and font customization features
* Day and hour label font resizing
* Dynamic event adding and removing
* Event tap, long press and event request callbacks
* Number of visible days customizable

### Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Most useful example code can be found in `Example > QVRWeekView > CalendarViewController or StartViewController`

### Requirements

This pod requires a minimum deployment target of iOS 9.0.

### Installation

QVRWeekView is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "QVRWeekView"
```

## Usage

### Setup

Once the framework is installed, there are two ways you can incorporate the `WeekView` into your project:

#### 1. Programatically

To add the WeekView programatically, simply import `QVRWeekView` into your code by adding:
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

To add the `WeekView` via the storyboard, simply add a View onto your View Controller and resize it or add constraints. Then go to the identity inspector of your view and select the Class to be `WeekView` and the module to be `QVRWeekView` (See image).

![image](http://i.imgur.com/5ymQ8iE.png "Identity Inspector - WeekView")

Then you should be all set!

### Working with WeekView

#### WeekView Delegate

`WeekView` has a delegate called `WeekViewDelegate`. For now this delegate contains only three functions:

| Function                            | Parameters                                                                             | Behaviour                                                             | Recommended use                                                     |
| ------------------------------|---------------------------------------------------------------------|--------------------------------------------------------|-------------------------------------------------------------|
| didLongPressDayView      | weekView:`WeekView`, date:`Date`                                       | Called when a dayView column is long pressed. The passed `date` contains which time point was pressed | Use this function to add individual user events           |
| didTapEvent                      | weekView:`WeekView`, eventId:`Int`                                    | Called when an event is tapped. `eventId` of the tapped event is passed                           | Use this function to prompt event editing or removal |
| loadNewEvents                 | weekView:`WeekView`, startDate:`Date` , endDate:`Date`  | Called when events are ready to be loaded. `startDate` and `endDate` indicate (inclusively) between which two dates events are required.  | Use this function to load in stored events                   |

#### WeekView Public functions

| Function                            | Parameters                           | Behaviour                                                             |
| ------------------------------|---------------------------------|--------------------------------------------------------|
| updateTimeDisplayed       | `\`                                         | Updates the time displayed by the hour indicator |
| showDay                           | date:`Date`                           | Scrolls the week view to the day passed by `date`  |
| showToday                        | `\`                                         | Scrolls the week view to today                              |
| loadEvents                        | eventsData:`[EventData]` | Loads, processes and displays the events provided by the `eventsData` array of `EventData`<sup>1</sup> objects.         |

#### EventData<sup>1</sup>

EventData is the main object used to communicate events between the WeekView and your code. EventData can be overriden.

| Variable/Function            | Purpose                           |
| ----------------------------|---------------------------------|
| id:`String`                    | A unique identifier for this event |
| title:`String`                 | A title that will be displayed for this event|
| startDate:`Date`            |  The start date for this event |
| endDate:`Date`              | The end date for this event |
| color:`UIColor`              | The main color for this event  |
| allDay:`Bool`                  | Indicates if this event is an all day event, all day events are displayed along the top bar |
| configureGradient()       | Used to configure a gradient that will be used to render your event instead of just a solid color |

### Customizing WeekView

Below is a table of all customizable properties of the `WeekView`

| Property | Description |
| ------------- |:-------------:|
| mainBackgroundColor:`UIColor`       | |
| defaultTopBarHeight:`CGFloat`     | |
| topBarColor:`UIColor`         | |
| sideBarWidth:`CGFloat`         | |
| dayLabelDefaultFont:`UIFont`         | |
| dayLabelTextColor:`UIColor`         | |
| dayLabelMinimumFontSize:`CGFloat`  | |
| hourLabelFont:`UIFont`         | |
| hourLabelTextColor:`UIColor`         | |
| hourLabelMinimumFontSize:`CGFloat`      | |
| allDayEventHeight:`CGFloat`         | |
| allDayEventVerticalSpacing:`CGFloat`    | |
| visibleDaysInPortraitMode:`Int`       | |
| visibleDaysInLandscapeMode:`Int`    | |
| eventLabelFont:`UIFont`         | |
| eventLabelTextColor:`UIColor`         | |
| eventLabelMinimumFontSize:`CGFloat`         | |
| eventShowTimeOfEvent:`Bool`               ||
| defaultDayViewColor:`UIColor`         | |
| weekendDayViewColor:`UIColor`         | |
| passedDayViewColor:`UIColor`         | |
| passedWeekendDayViewColor:`UIColor`         | |
| todayViewColor:`UIColor`         | |
| dayViewHourIndicatorColor:`UIColor`         | |
| dayViewHourIndicatorThickness:`CGFloat`         | |
| dayViewMainSeparatorColor:`UIColor`         | |
| dayViewMainSeparatorThickness:`CGFloat`         | |
| dayViewDashedSeparatorColor:`UIColor`         | |
| dayViewDashedSeparatorThickness:`CGFloat`         | |
| dayViewDashedSeparatorPattern:`[NSNumber]`         | |
| dayViewCellHeight:`CGFloat`         | |
| portraitDayViewSideSpacing:`CGFloat`         | | 
| landscapeDayViewSideSpacing:`CGFloat`         | | 
| portraitDayViewVerticalSpacing:`CGFloat`         | |
| landscapeDayViewVerticalSpacing:`CGFloat`         | |
| velocityOffsetMultiplier:`CGFloat`         | |
| showPreviewOnLongPress: `Bool`            | |
| allDayEventsSpreadOnX: `Bool`            | Sets spread all day events on x axis, if not true than spread will be made on y axis. |

## How it works

The main WeekView view is a subclass of UIView. The view layout is retrieved from the WeekView xib file. WeekView contains a top and side bar sub view. The side bar contains an HourSideBarView which displays the hours. WeekView also contains a DayScrollView (UIScrollView subclass) which controls vertical scrolling and also delegates and contains a DayCollectionView (UICollectionView subclass) which controls the horizontal scrolling. DayCollectionView cells are DayViewCells, whose view is generated programtically (due to inefficiencies caused by auto-layout).

WeekView handles all top level operations such as pinch gestures and orientation change. Scrolling of the top and side bar is handled by a function inside of WeekView which is called by the DayScrollView when scrolling. Top bar day labels are generated, displayed and discarded simulaneously with DayCollectionView cells by the WeekView.

## Upcoming features

- [x] Ability to add and remove events
- [x] Event color customization
- [x] Extra customization features
- [x] Improved UI features
- [x] Increased event processing efficiency
- [ ] Add: testing project, where pod can be tested
- [ ] Clean: remove useless folders and unify the naming across them
- [ ] Re-write: how all day events are added to the view using autolayout
- [ ] Add: CI for building/testing
- [ ] Add: tests
- [ ] Add: scroll to all day events

## Author

Reinert Lemmens, reilemx@gmail.com

## License

QVRWeekView is available under the MIT license. See the LICENSE file for more info.
