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

        let xPadding = layout.eventLabelHorizontalTextPadding
        let yPadding = layout.eventLabelVerticalTextPadding
        
        // Configure event text layer
        let eventTextLayer = CATextLayer()
        eventTextLayer.isWrapped = true
        eventTextLayer.contentsScale = UIScreen.main.scale
        eventTextLayer.string = event.getDisplayString(
            withMainFont: layout.eventLabelFont,
            infoFont: layout.eventLabelInfoFont,
            andColor: layout.eventLabelTextColor)
        
        eventTextLayer.frame = CGRect(
            x: frame.origin.x + xPadding,
            y: frame.origin.y + yPadding,
            width: frame.width - 2 * xPadding,
            height: frame.height - 2 * yPadding)
        self.addSublayer(eventTextLayer)
        
        // Add tags at the bottom if available
        if !event.tags.isEmpty {
            let tagHeight: CGFloat = 18
            let bottomMargin: CGFloat = 4
            let tagsY = frame.origin.y + frame.height - yPadding - tagHeight - bottomMargin
            
            // Only render tags if there's enough space
            if tagsY > frame.origin.y + yPadding + 20 {
                addTagsLayers(
                    tags: event.tags,
                    x: frame.origin.x + xPadding,
                    y: tagsY,
                    maxWidth: frame.width - 2 * xPadding,
                    tagHeight: tagHeight,
                    eventColor: event.color)
            }
        }
    }
    
    private func addTagsLayers(tags: [String], x: CGFloat, y: CGFloat, maxWidth: CGFloat, tagHeight: CGFloat, eventColor: UIColor) {
        let tagSpacing: CGFloat = 4
        let tagPadding: CGFloat = 6
        let tagCornerRadius: CGFloat = tagHeight / 2
        let iconSize: CGFloat = tagHeight // Icons same height as pills
        
        var currentX: CGFloat = x
        
        for tag in tags {
            let tagLower = tag.lowercased()
            let iconName = getIconForTag(tagLower)
            var iconImage: UIImage? = nil
            
            // Try to load icon if it exists
            if let iconName = iconName {
                iconImage = loadIconImage(named: iconName)
            }
            
            // Calculate tag width
            var tagWidth: CGFloat
            let tagFont = UIFont(name: "Montserrat-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium)
            
            if iconImage != nil {
                tagWidth = iconSize // Just icon width, no padding
            } else {
                // Text only tags with padding (fallback when icon not found)
                let tagText = tag as NSString
                let textWidth = tagText.size(withAttributes: [.font: tagFont]).width
                tagWidth = textWidth + (tagPadding * 2)
            }
            
            // Check if tag fits on current line
            if currentX + tagWidth > x + maxWidth {
                break // Stop if doesn't fit
            }
            
            if let image = iconImage {
                // Create icon layer from Assets (no background pill)
                let iconLayer = CALayer()
                iconLayer.contents = image.cgImage
                iconLayer.frame = CGRect(
                    x: currentX,
                    y: y,
                    width: iconSize,
                    height: iconSize
                )
                iconLayer.contentsGravity = .resizeAspect
                // Use destination out blend mode for transparent icons
                iconLayer.compositingFilter = "destinationOut"
                self.addSublayer(iconLayer)
            } else {
                // Create tag background layer (white pill for text fallback)
                let tagBackgroundLayer = CALayer()
                tagBackgroundLayer.frame = CGRect(x: currentX, y: y, width: tagWidth, height: tagHeight)
                tagBackgroundLayer.backgroundColor = UIColor.white.cgColor
                tagBackgroundLayer.cornerRadius = tagCornerRadius
                self.addSublayer(tagBackgroundLayer)
                
                // Create tag text layer with Montserrat Medium
                let tagTextLayer = CATextLayer()
                let tagText = tag as NSString
                let textWidth = tagText.size(withAttributes: [.font: tagFont]).width
                
                tagTextLayer.frame = CGRect(
                    x: currentX + tagPadding,
                    y: y + 3,
                    width: textWidth,
                    height: tagHeight - 6
                )
                tagTextLayer.string = tag
                tagTextLayer.font = tagFont
                tagTextLayer.fontSize = 10
                tagTextLayer.foregroundColor = eventColor.cgColor
                tagTextLayer.contentsScale = UIScreen.main.scale
                tagTextLayer.alignmentMode = .center
                self.addSublayer(tagTextLayer)
            }
            
            // Move x position for next tag
            currentX += tagWidth + tagSpacing
        }
    }
    
    private func getIconForTag(_ tag: String) -> String? {
        switch tag {
        case "bed":
            return "bed"
        case "alert":
            return "alert"
        case "fail":
            return "fail"
        case "success":
            return "success"
        case "drink":
            return "drink"
        default:
            return nil
        }
    }
    
    private func loadIconImage(named: String) -> UIImage? {
        let bundle = Bundle(for: EventLayer.self)
        
        // Try SVG first
        if let svgPath = bundle.path(forResource: named, ofType: "svg", inDirectory: "Assets/tags"),
           let svgData = try? Data(contentsOf: URL(fileURLWithPath: svgPath)) {
            if #available(iOS 13.0, *), let image = UIImage(data: svgData) {
                return image
            }
        }
        
        // Try PNG
        if let pngPath = bundle.path(forResource: named, ofType: "png", inDirectory: "Assets/tags"),
           let image = UIImage(contentsOfFile: pngPath) {
            return image
        }
        
        // Try PDF
        if let pdfPath = bundle.path(forResource: named, ofType: "pdf", inDirectory: "Assets/tags"),
           let image = UIImage(contentsOfFile: pdfPath) {
            return image
        }
        
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
