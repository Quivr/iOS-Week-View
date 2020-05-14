//
//  EventLayer.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 25/08/2019.
//

import Foundation

class EventLayer: CALayer {
    override init(layer: Any) {
        super.init(layer: layer)
    }

    init(withFrame frame: CGRect, layout: DayViewCellLayout, andEvent event: EventData) {
        super.init()
        self.bounds = frame
        self.frame = frame

        // Configure gradient and colour layer
        if let gradient = event.getGradientLayer(withFrame: frame) {
            self.backgroundColor = UIColor.clear.cgColor
            self.addSublayer(gradient)
        } else {
            self.backgroundColor = event.color.cgColor
        }

        // Configure event text layer
        let eventTextLayer = CATextLayer()
        eventTextLayer.isWrapped = true
        eventTextLayer.contentsScale = UIScreen.main.scale
        eventTextLayer.string = event.getDisplayString(withMainFont: layout.eventLabelFont,
                                                       infoFont: layout.eventLabelInfoFont,
                                                       andColor: layout.eventLabelTextColor)

        let xPadding = layout.eventLabelHorizontalTextPadding
        let yPadding = layout.eventLabelVerticalTextPadding
        eventTextLayer.frame = CGRect(x: frame.origin.x + xPadding,
                                      y: frame.origin.y + yPadding,
                                      width: frame.width - 2*xPadding,
                                      height: frame.height - 2*yPadding)
        self.addSublayer(eventTextLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
