# QVRWeekView

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
| didLongPressDayView      | weekView:`WeekView`, date:`Date`                                       | Called when a dayView column is long pressed. The passed `date` contains which time point was pressed | Use this to trigger the creation of an event       |
| didTapEvent                      | weekView:`WeekView`, eventId:`Int`                                    | Called when an event is tapped. `eventId` of the tapped event is passed                           | Use this to prompt event editing or removal |
| eventLoadRequest                 | weekView:`WeekView`, startDate:`Date` , endDate:`Date`  | Called when events are ready to be loaded. `startDate` and `endDate` indicate (inclusively) between which two dates events are required.  | Use this to load in stored events |
| activeDayChanged                 | weekView:`WeekView`, date: `Date` | Called when the current leftmost day changes.  | Use this to keep track of current active day |
| didEndZooming | weekView:`WeekView`, scale: `Double` | Called when zooming stops, the scale is the current zoomScale | Use this to persist the zoom scale of the WeekView |
| didEndVerticalScrolling | weekView:`WeekView`, top: `Double`, bottom: `Double` | Called when vertical scrolling stops. The top an bottom values are percentages values of how far down the screen is. | Use this to persist vertical position of the WeekView |

#### WeekView Public Functions

| Function                            | Parameters                           | Behaviour                                                             |
| ------------------------------|---------------------------------|--------------------------------------------------------|
| updateTimeDisplayed       | `\`                                         | Updates the time displayed by the hour indicator |
| showDay                           | date:`Date`                           | Scrolls the week view to the day passed by `date`  |
| showToday                        | `\`                                         | Scrolls the week view to today                              |
| loadEvents                        | eventsData:`[EventData]` | Loads, processes and displays the events provided by the `eventsData` array of `EventData`<sup>1</sup> objects. Passing an empty array removes all visible events.  |
| redrawEvents | | Triggers a `setNeedsLayout` on all DayViewCells and will trigger a redrawing of all events |

#### WeekView Public Properties

| Property                            | Type                             | Description                                                             |
| ------------------------------|---------------------------|--------------------------------------------------------|
| allVisibleEvents          | `[EventData]`                    | An array of EventData of the events currently visible on screen |
| visibleDayDateRange | `ClosedRange<DayDate>` | A ClosedRange of DayDates of the day columns which are currently visible on screen  |
| delegate | `WeekViewDelegate?` | The delegate of this WeekView |

#### EventData<sup>1</sup>

EventData is the main object used to communicate events between the WeekView and your code. EventData can be overriden.

| Variable/Function            | Purpose                           |
| ----------------------------|---------------------------------|
| id:`String`                    | A unique identifier for this event |
| title:`String`                 | A title that will be displayed for this event |
| locating:`String`                 | The "location" of this event (or any other data you wish to be displayed alongside the title in an event) |
| startDate:`Date`            |  The start date for this event |
| endDate:`Date`              | The end date for this event |
| color:`UIColor`              | The main color for this event  |
| allDay:`Bool`                  | Indicates if this event is an all day event, all day events are displayed along the top bar |
| `configureGradient(CAGradientLayer?) -> Void`       | Use to configure a gradient that will be used to render your event instead of just a solid color |

#### Saving and Persisting Events

Events can be stored in Core Data (the following guide assumes some basic knowledge of Core Data):

1. Create a new Core Data model if you don't have one already. Create a new Entity in this model.
2. Add a new Attribute of type  `Transformable` to the new Entity.
2. Select the new Attribute and make sure its `CustomClass` is set to (this can be changed in the right-hand side menu):
    - `EventDataArray` if you want to store an array of events
    - `EventData` if you want to store a single event
3. If you are getting Undeclared Type warnings, you may need to add `@import QVRWeekView` to your `[ProjectName]-Bridging-Header.h` file.
4. You can now use the new Core Data Entity to persist `EventData` objects.

The `EventDataArray` class has a single variable:  `eventsData: [EventData]` and is simply used as a proxy to store an array of events.

A detailed example can be found in the example Project folder `/Example`. A more detailed guide can be found [here](https://medium.com/@rezafarahani/store-array-of-custom-object-in-coredata-bea77b9eb629).

### Customizing WeekView

Below is a table of all customizable properties of the `WeekView`

| Property | Description | Default |
| ------------- |:----------:|:-:|
| mainBackgroundColor:`UIColor`       | The background color of the WeekView. | `dark grey: #cacaca` |
| defaultTopBarHeight:`CGFloat`     | The default height of the top bar containing the day labels. | `35` |
| topBarColor:`UIColor`         | The color of the top bar containing the day labels. | `grey: #dcdcdc` |
| sideBarWidth:`CGFloat`         | The width of the sidebar containing the hour labels. | `25` |
| sideBarColor:`UIColor`         | The color of the sidebar containing the hour labels. | `dark grey: #cacaca` |
| dayLabelDefaultFont:`UIFont`         | The default font the the day labels. | `boldSystemFont size: 14` |
| dayLabelTextColor:`UIColor`         | The text color of the day labels. | `black: #000` |
| dayLabelTodayTextColor:`UIColor`         | The text color of the today day label. | `dark blue: #14426f` |
| dayLabelMinimumFontSize:`CGFloat`  | The minimum day label font size. Used during automatic resizing. | `8` |
| dayLabelShortDateFormat:`String`      | The date format of the day label when there is not enough space to display the normal date format. Date formats can be found [here](http://nsdateformatter.com/). | `d MMM` |
| dayLabelNormalDateFormat:`String`      | The date format of the day label when there is not enough space to display the long date format. Date formats can be found [here](http://nsdateformatter.com/). | `E d MMM` |
| dayLabelLongDateFormat:`String`      | The longest date format of the day label, only shown when there is enough space to display it. Date formats can be found [here](http://nsdateformatter.com/). |  `E d MMM y` |
| dayLabelDateLocale:`Locale`      | Locale used by the day label formatter. Locales can be found [here](https://gist.github.com/jacobbubu/1836273) | `NSLocale.current` |
| hourLabelFont:`UIFont`         | The font the the hour labels. | `boldSystemFont size: 12` |
| hourLabelTextColor:`UIColor`         | The text color of the hour labels. | `black #000` |
| hourLabelMinimumFontSize:`CGFloat`      | The minimum day label font size. Used during automatic resizing. | `6` |
| hourLabelDateFormat:`String`      | The date format used to display the hours in the side bar. | `HH` |
| allDayEventHeight:`CGFloat`         | The height of an all day event. | `40` |
| allDayEventVerticalSpacing:`CGFloat`    | The vertical spacing above and below an all day event. | `5` |
| allDayEventsSpreadOnX:`Bool`    | When enabled, all day events are displayed next to each other, instead of above and below each other. | `true` |
|autoConvertAllDayEvents:`Bool`| When enabled, events that cross multiple days will be converted to all day events. | `true` |
| visibleDaysInPortraitMode:`Int`       | The amount of day columns visible in portrait mode. | `2` |
| visibleDaysInLandscapeMode:`Int`    | The amount day columns visible in landscape mode. | `7` |
| eventLabelFont:`UIFont`         | The font of the text inside events. | `boldSystemFont size: 12` |
| eventLabelInfoFont:`UIFont`         | The info font of the text inside events. | `boldFont size: 12` |
| eventLabelTextColor:`UIColor`         | The color of the text inside events. | `white #fff` |
| eventLabelHorizontalTextPadding:`CGFloat`         | Horizontal padding of the text within event labels. | `2` |
| eventLabelVerticalTextPadding:`CGFloat`         | Vertical padding of the text within event labels. | `2` |
| eventStyleCallback:`(CALayer, EventData?) -> Void` | Use this callback to customise an Event layer any way you want. The EventData will be nil if it is the Preview Event layer that is being rendered. Example usage in CalendarViewController. | `nil` |
| previewEventText:`String`         | The text shown inside the preview event. | `New Event` |
| previewEventColor:`UIColor`         | The color of the preview event. | `random color` |
| previewEventHeightInHours:`Double`         | Height of the preview event in hours. | `2.0` |
| previewEventPrecisionInMinutes:`Double`         | The number of minutes the preview event will snap to. Ex: 15.0 will snap preview event to nearest 15 minutes. | `15.0` |
| showPreviewOnLongPress:`Bool`         | When enabled a preview event will be displayed on a long press. | `true` |
| defaultDayViewColor:`UIColor`         | The default color of a day column. | `light grey #f8f8f8` |
| weekendDayViewColor:`UIColor`         | The color of a weekend day column. | `grey #eaeaea` |
| passedDayViewColor:`UIColor`         | The color of a day column that is in the past. | `grey #f0f0f0` |
| passedWeekendDayViewColor:`UIColor`         | The color of a weekend day column that is in the past. | `grey #e4e4e4` |
| todayViewColor:`UIColor`         | The color of today's day column. | `light grey #f8f8f8` |
| showTodayTimeOverlay:`Bool`         | Show or hide "current time" overlay in the today day view cell. | `true` |
| dayViewCellInitialHeight:`CGFloat`         | Height for the day columns. This is the initial height for zoom scale = 1.0. | `1400` |
| dayViewHourIndicatorColor:`UIColor`         | Color of the current hour indicator. | `very dark grey #5a5a5a` |
| dayViewHourIndicatorThickness:`CGFloat`         | Thickness (or height) of the current hour indicator. | `3` |
| dayViewMainSeparatorColor:`UIColor`         | Color of the main hour separators in the day view cells. Main separators are full lines and not dashed. | `dark grey: #cacaca` |
| dayViewMainSeparatorThickness:`CGFloat`         | Thickness of the main hour separators in the day view cells. Main separators are full lines and not dashed. | `1` |
| dayViewDashedSeparatorColor:`UIColor`         | Color of the dashed/dotted hour separators in the day view cells. | `dark grey: #cacaca` |
| dayViewDashedSeparatorThickness:`CGFloat`         | Thickness of the dashed/dotted hour separators in the day view cells. | `1` |
| dayViewDashedSeparatorPattern:`[NSNumber]`         | Sets the pattern for the dashed/dotted hour separators. Requires an array of NSNumbers. Example 1: (10, 5) will set a pattern of 10 points drawn, 5 points empty, repeated. Example 2: (3, 4, 9, 2) will set a pattern of 4 points drawn, 4 points empty, 9 points drawn, 2 points empty, repeated. See [Apple API](https://developer.apple.com/documentation/quartzcore/cashapelayer/1521921-linedashpattern) for additional information on pattern drawing. | `[3, 1]` |
| portraitDayViewSideSpacing:`CGFloat`         | Amount of spacing in between day columns when in portrait mode. |  `5` |
| landscapeDayViewSideSpacing:`CGFloat`         | Amount of spacing in between day columns when in landscape mode. | `1` |
| portraitDayViewVerticalSpacing:`CGFloat`         | Amount of spacing above and below day columns when in portrait mode. | `15` |
| landscapeDayViewVerticalSpacing:`CGFloat`         | Amount of spacing above and below day columns when in landscape mode. | `10` |
| minimumZoomScale:`CGFloat`         | The minimum zoom scale to which the weekview can be zoomed. Ex. 0.5 means that the weekview can be zoomed to half the original given dayViewCellHeight. | `0.75` |
| currentZoomScale:`CGFloat`         | The current zoom scale to which the weekview will be zoomed. Ex. 0.5 means that the weekview will be zoomed to half the original given dayViewCellHeight. | `1.0` |
| maximumZoomScale:`CGFloat`         | The maximum zoom scale to which the weekview can be zoomed. Ex. 2.0 means that the weekview can be zoomed to double the original given dayViewCellHeight. | `3.0` |
| velocityOffsetMultiplier:`CGFloat`         | Sensitivity for horizontal scrolling. A higher number will multiply input velocity more and thus result in more cells being skipped when scrolling. | `0.75` |
| horizontalScrolling:`HorizontalScrolling` | Used to determine horizontal scrolling behaviour. `.infinite` is infinite scrolling, `.finite(number, startDate)` is finite scrolling for a given number of days from the starting date. | `.infinite`

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
