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
        if !event.eventTags.isEmpty {
            let tagHeight = layout.tagHeight
            let bottomMargin = layout.tagVerticalMargin
            let tagsY = frame.origin.y + frame.height - yPadding - tagHeight - bottomMargin
            
            // Only render tags if there's enough space
            if tagsY > frame.origin.y + yPadding + 20 {
                addTagsLayers(
                    eventTags: event.eventTags,
                    x: frame.origin.x + xPadding,
                    y: tagsY,
                    maxWidth: frame.width - 2 * xPadding,
                    layout: layout,
                    eventColor: event.color)
            }
        }
    }
    
    private func addTagsLayers(eventTags: [EventTag], x: CGFloat, y: CGFloat, maxWidth: CGFloat, layout: DayViewCellLayout, eventColor: UIColor) {
        let tagHeight = layout.tagHeight
        let tagSpacing = layout.tagSpacing
        let tagCornerRadius = layout.tagCornerRadius
        let tagTextSize = layout.tagTextSize
        let tagPadding: CGFloat = 6
        let iconSize: CGFloat = tagHeight
        
        var currentX: CGFloat = x
        
        // Process tags
        for eventTag in eventTags {
            let tagName = eventTag.name
            let tagColor = eventTag.color
            
            let tagLower = tagName.lowercased()
            
            // Try to load icon for any tag (automatically detects from Images.xcassets/tags/)
            let iconImage = loadIconImage(named: tagLower)
            
            // Check if tag is emoji-only
            let isEmojiOnly = isEmoji(tagName)
            
            // Calculate tag width
            var tagWidth: CGFloat
            let tagFont = UIFont(name: "Montserrat-Medium", size: tagTextSize) ?? UIFont.systemFont(ofSize: tagTextSize, weight: .medium)
            
            if iconImage != nil {
                // Icon from asset
                tagWidth = iconSize
            } else if isEmojiOnly {
                // Emoji-only: no background, just emoji text
                let emojiSize = tagName.size(withAttributes: [.font: UIFont.systemFont(ofSize: tagTextSize + 4)])
                tagWidth = emojiSize.width + 4 // Small margin around emoji
            } else {
                // Text-only with color background
                let tagText = tagName as NSString
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
                iconLayer.compositingFilter = "destinationOut"
                self.addSublayer(iconLayer)
            } else if isEmojiOnly {
                // Render emoji-only text without background (no foregroundColor set to preserve emoji colors)
                let emojiTextLayer = CATextLayer()
                
                emojiTextLayer.frame = CGRect(
                    x: currentX,
                    y: y,
                    width: tagWidth,
                    height: tagHeight
                )
                emojiTextLayer.string = tagName
                emojiTextLayer.font = UIFont.systemFont(ofSize: tagTextSize + 4)
                emojiTextLayer.fontSize = tagTextSize + 4
                emojiTextLayer.contentsScale = UIScreen.main.scale
                emojiTextLayer.alignmentMode = .center
                emojiTextLayer.isWrapped = false
                self.addSublayer(emojiTextLayer)
            } else {
                // Text with tag color background
                let tagBackgroundLayer = CALayer()
                
                tagBackgroundLayer.frame = CGRect(x: currentX, y: y, width: tagWidth, height: tagHeight)
                tagBackgroundLayer.backgroundColor = tagColor.cgColor
                tagBackgroundLayer.cornerRadius = tagCornerRadius
                self.addSublayer(tagBackgroundLayer)
                
                // Create tag text layer with event color (creates stamp out effect)
                let tagTextLayer = CATextLayer()
                let tagText = tagName as NSString
                let textWidth = tagText.size(withAttributes: [.font: tagFont]).width
                
                tagTextLayer.frame = CGRect(
                    x: currentX + tagPadding,
                    y: y + 3,
                    width: textWidth,
                    height: tagHeight - 6
                )
                tagTextLayer.string = tagName
                tagTextLayer.font = tagFont
                tagTextLayer.fontSize = tagTextSize
                tagTextLayer.foregroundColor = eventColor.cgColor
                tagTextLayer.contentsScale = UIScreen.main.scale
                tagTextLayer.alignmentMode = .center
                self.addSublayer(tagTextLayer)
            }
            
            // Move x position for next tag
            currentX += tagWidth + tagSpacing
        }
    }

        let cleaned = string.trimmingCharacters(in: .whitespaces)
        if cleaned.isEmpty {
            return false
        }
        
        // Check if all characters are emoji
        for scalar in cleaned.unicodeScalars {
            // Skip variation selectors and joiners
            if scalar.properties.isEmoji || 
               scalar.properties.isEmojiComponent ||
               scalar == "\u{200D}" { // Zero-width joiner
                continue
            }
            // If we encounter a non-emoji character, it's not emoji-only
            if !scalar.properties.isWhitespace {
                return false
            }
        }
        return true
    }
    
    private func loadIconImage(named: String) -> UIImage? {
        // Try to load from main app bundle under tags namespace (Images.xcassets/tags/)
        if let image = UIImage(named: "tags/\(named)", in: Bundle.main, compatibleWith: nil) {
            return image
        }
        
        // Try without namespace in main bundle
        if let image = UIImage(named: named, in: Bundle.main, compatibleWith: nil) {
            return image
        }
        
        // Try from framework bundle under tags namespace
        let bundle = Bundle(for: EventLayer.self)
        
        if let image = UIImage(named: "tags/\(named)", in: bundle, compatibleWith: nil) {
            return image
        }
        
        // Try without namespace in framework bundle
        if let image = UIImage(named: named, in: bundle, compatibleWith: nil) {
            return image
        }
        
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
