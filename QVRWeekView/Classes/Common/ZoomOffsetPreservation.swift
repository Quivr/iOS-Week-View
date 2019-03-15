//
//  ZoomOffsetPreservation.swift
//  Pods
//
//  Created by Reinert Lemmens on 14/03/2019.
//

import Foundation

/**
 Enum is used to determine what type of offset preservation method is used when customising the currentZoomScale.
 */
public enum ZoomOffsetPreservation {
    // The top offset of the dayScrollView is preserved.
    // This means that the hour located at the top of the DayScrollView after
    // setting the zoom will be the same hour as before setting the zoom.
    case top
    // The center offset of the dayScrollView is preserved.
    // This means that the hour located at the center of the DayScrollView after
    // setting the zoom will be the same hour as before setting the zoom.
    case center
    // The bottom offset of the dayScrollView is preserved.
    // This means that the hour located at the bottom of the DayScrollView after
    // setting the zoom will be the same hour as before setting the zoom.
    case bottom
    // No offset is preserved and the vertical scroll is reset to display the current hour
    // as close to the top of the DayScrollView as possible.
    case reset
    // No attempt is made to preserve any offset.
    case none
}
