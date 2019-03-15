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

#### WeekView Public Functions

| Function                            | Parameters                           | Behaviour                                                             |
| ------------------------------|---------------------------------|--------------------------------------------------------|
| updateTimeDisplayed       | `\`                                         | Updates the time displayed by the hour indicator |
| showDay                           | date:`Date`                           | Scrolls the week view to the day passed by `date`  |
| showToday                        | `\`                                         | Scrolls the week view to today                              |
| loadEvents                        | eventsData:`[EventData]` | Loads, processes and displays the events provided by the `eventsData` array of `EventData`<sup>1</sup> objects.         |

#### WeekView Public functions

| Property                            | Type                             | Description                                                             |
| ------------------------------|---------------------------|--------------------------------------------------------|
| allVisibleEvents          | `[EventData]`                    | An array of EventData of the events currently visible on screen |
| visibleDayDateRange | `ClosedRange<DayDate>` | A ClosedRange of DayDates of the day columns which are currently visible on screen  |

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
| mainBackgroundColor:`UIColor`       | The background color of the WeekView. |
| defaultTopBarHeight:`CGFloat`     | The default height of the top bar containing the day labels. |
| topBarColor:`UIColor`         | The color of the top bar containing the day labels. |
| sideBarWidth:`CGFloat`         | The width of the sidebar containing the hour labels. |
| dayLabelDefaultFont:`UIFont`         | The default font the the day labels. |
| dayLabelTextColor:`UIColor`         | The text color of the day labels. |
| dayLabelMinimumFontSize:`CGFloat`  | The minimum day label font size. Used during automatic resizing. |
| dayLabelShortDateFormat:`String`      | The date format of the day label when there is not enough space to display the normal date format. Date formats can be found [here](http://nsdateformatter.com/). |
| dayLabelNormalDateFormat:`String`      | The date format of the day label when there is not enough space to display the long date format. Date formats can be found [here](http://nsdateformatter.com/). |
| dayLabelLongDateFormat:`String`      | The longest date format of the day label, only shown when there is enough space to display it. Date formats can be found [here](http://nsdateformatter.com/). |  
| dayLabelDateLocaleIdentifier:`String`      | Locale used by the day label formatter. Locales can be found [here](https://gist.github.com/jacobbubu/1836273) |
| hourLabelFont:`UIFont`         | The font the the hour labels. |
| hourLabelTextColor:`UIColor`         | The text color of the hour labels. |
| hourLabelMinimumFontSize:`CGFloat`      | The minimum day label font size. Used during automatic resizing. |
| hourLabelDateFormat:`String`      | The date format used to display the hours in the side bar. |
| allDayEventHeight:`CGFloat`         | The height of an all day event. |
| allDayEventVerticalSpacing:`CGFloat`    | The vertical spacing above and below an all day event. |
| allDayEventsSpreadOnX:`Bool`    | When enabled, all day events are displayed next to each other, instead of above and below each other. |
| visibleDaysInPortraitMode:`Int`       | How many day columns are visible in portrait mode. |
| visibleDaysInLandscapeMode:`Int`    | How many day columns are visible in landscape mode. |
| eventLabelFont:`UIFont`         | The font of the text inside events. |
| eventLabelTextColor:`UIColor`         | The color of the text inside events. |
| eventLabelMinimumFontSize:`CGFloat`         | The minimum size of the text inside events. |
| eventLabelFontResizingEnabled:`Bool`         | Determines if font resizing is used inside event labels. **This feature may be very laggy and slow.** |
| eventLabelHorizontalTextPadding:`CGFloat`         | Horizontal padding of the text within event labels. |
| eventLabelVerticalTextPadding:`CGFloat`         | Vertical padding of the text within event labels. |
| previewEventText:`String`         | The text shown inside the preview event. |
| previewEventColor:`UIColor`         | The color of the preview event. |
| previewEventHeightInHours:`Double`         | Height of the preview event in hours. |
| previewEventPrecisionInMinutes:`Double`         | The number of minutes the preview event will snap to. Ex: 15.0 will snap preview event to nearest 15 minutes. |
| showPreviewOnLongPress:`Bool`         | When enabled a preview event will be displayed on a long press. |
| defaultDayViewColor:`UIColor`         | The default color of a day column. |
| weekendDayViewColor:`UIColor`         | The color of a weekend day column. |
| passedDayViewColor:`UIColor`         | The color of a day column that is in the past. |
| passedWeekendDayViewColor:`UIColor`         | The color of a weekend day column that is in the past. |
| todayViewColor:`UIColor`         | The color of today's day column. ||
| dayViewHourIndicatorColor:`UIColor`         | Color of the current hour indicator. |
| dayViewHourIndicatorThickness:`CGFloat`         | Thickness (or height) of the current hour indicator. |
| dayViewMainSeparatorColor:`UIColor`         | Color of the main hour separators in the day view cells. Main separators are full lines and not dashed. |
| dayViewMainSeparatorThickness:`CGFloat`         | Thickness of the main hour separators in the day view cells. Main separators are full lines and not dashed. |
| dayViewDashedSeparatorColor:`UIColor`         | Color of the dashed/dotted hour separators in the day view cells. |
| dayViewDashedSeparatorThickness:`CGFloat`         | Thickness of the dashed/dotted hour separators in the day view cells. |
| dayViewDashedSeparatorPattern:`[NSNumber]`         | Sets the pattern for the dashed/dotted hour separators. Requires an array of NSNumbers. Example 1: (10, 5) will set a pattern of 10 points drawn, 5 points empty, repeated. Example 2: (3, 4, 9, 2) will set a pattern of 4 points drawn, 4 points empty, 9 points drawn, 2 points empty, repeated. See [Apple API](https://developer.apple.com/documentation/quartzcore/cashapelayer/1521921-linedashpattern) for additional information on pattern drawing. |
| dayViewCellHeight:`CGFloat`         | Height for the day columns. This is the initial height for zoom scale = 1.0. |
| portraitDayViewSideSpacing:`CGFloat`         | Amount of spacing in between day columns when in portrait mode. | 
| landscapeDayViewSideSpacing:`CGFloat`         | Amount of spacing in between day columns when in landscape mode. | 
| portraitDayViewVerticalSpacing:`CGFloat`         | Amount of spacing above and below day columns when in portrait mode. |
| landscapeDayViewVerticalSpacing:`CGFloat`         | Amount of spacing above and below day columns when in landscape mode. |
| minimumZoomScale:`CGFloat`         | The minimum zoom scale to which the weekview can be zoomed. Ex. 0.5 means that the weekview can be zoomed to half the original given hourHeight. |
| currentZoomScale:`CGFloat`         | The current zoom scale to which the weekview will be zoomed. Ex. 0.5 means that the weekview will be zoomed to half the original given hourHeight. |
| maximumZoomScale:`CGFloat`         | The maximum zoom scale to which the weekview can be zoomed. Ex. 2.0 means that the weekview can be zoomed to double the original given hourHeight. |
| velocityOffsetMultiplier:`CGFloat`         | Sensitivity for horizontal scrolling. A higher number will multiply input velocity more and thus result in more cells being skipped when scrolling. |

## How it works

The main WeekView view is a subclass of UIView. The view layout is retrieved from the WeekView xib file. WeekView contains a top and side bar sub view. The side bar contains an HourSideBarView which displays the hours. WeekView also contains a DayScrollView (UIScrollView subclass) which controls vertical scrolling and also delegates and contains a DayCollectionView (UICollectionView subclass) which controls the horizontal scrolling. DayCollectionView cells are DayViewCells, whose view is generated programtically (due to inefficiencies caused by auto-layout).

WeekView handles all top level operations such as pinch gestures and orientation change. Scrolling of the top and side bar is handled by a function inside of WeekView which is called by the DayScrollView when scrolling. Top bar day labels are generated, displayed and discarded simulaneously with DayCollectionView cells by the WeekView.

## Upcoming features

- [x] Ability to add and remove events
- [x] Event color customization
- [x] Extra customization features
- [x] Improved UI features
- [x] Increased event processing efficiency
- [ ] Add scroll to all day events

## Author

Reinert Lemmens, reilemx@gmail.com

## License

QVRWeekView is available under the MIT license. See the LICENSE file for more info.
