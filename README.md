# QVRWeekView

[![CI Status](http://img.shields.io/travis/reilem/QVRWeekView.svg?style=flat)](https://travis-ci.org/reilem/QVRWeekView)
[![Version](https://img.shields.io/cocoapods/v/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)
[![License](https://img.shields.io/cocoapods/l/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)
[![Platform](https://img.shields.io/cocoapods/p/QVRWeekView.svg?style=flat)](http://cocoapods.org/pods/QVRWeekView)

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

QVRWeekView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QVRWeekView"
```

## Usage

Once the framework is installed, simply import QVRWeekView into your code and insert the WeekView class into your program either through code or through a storyboard/xib. WeekView is a subclass of UIView and can be used as such. For now the only methods publicly available are some customization functions, and a few useful features such as "show today" and "update time".

## How it works

The main WeekView view is a subclass of UIView. The view layout is retrieved from the WeekView xib file. WeekView contains a top and side bar sub view. The side bar contains an HourSideBarView which displays the hours. WeekView also contains a DayScrollView (UIScrollView subclass) which controls vertical scrolling and also delegates a DayCollectionView (UICollectionView subclass) which controls the horizontal scrolling. DayCollectionView cells are DayViewCells, whose view is generated programtically (due to inefficiencies caused by auto-layout).

WeekView handles top level operations such as pinch gestures and orientation change. Scrolling of the top and side bar is also handled by a function inside of WeekView which is called by the DayScrollView when scrolling. Top bar day labels are generated, displayed and discarded simulaneously with DayCollectionView cells.

## Author

Reinert Lemmens, reilemx@gmail.com

## License

QVRWeekView is available under the MIT license. See the LICENSE file for more info.
