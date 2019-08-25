//
//  EventLayer.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 25/08/2019.
//

import Foundation

class EventLayer: CAShapeLayer {
    init(withFrame frame: CGRect, andEvent event: EventData) {
        super.init()
        self.path = CGPath(rect: frame, transform: nil)

        // Configure gradient and colour layer
        if let gradient = event.getGradientLayer(withFrame: frame) {
            self.fillColor = UIColor.clear.cgColor
            self.addSublayer(gradient)
        } else {
            self.fillColor = event.color.cgColor
        }

        // Configure event text layer
        let eventTextLayer = CATextLayer()
        eventTextLayer.isWrapped = true
        eventTextLayer.contentsScale = UIScreen.main.scale
        eventTextLayer.string = event.getDisplayString()

        let xPadding = TextVariables.eventLabelHorizontalTextPadding
        let yPadding = TextVariables.eventLabelVerticalTextPadding
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
