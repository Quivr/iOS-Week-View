

import UIKit

class EventView: UIView {

    // Main text displaying label
    @IBOutlet var textLabel: UILabel!
    // Delegate handling tap events
    weak var delegate: EventViewDelegate?
    // The actual view being rendered
    var view:UIView?
    // EventView's event data
    var eventData: EventData!
    
    init(withData data:EventData, andFrame frame:CGRect) {
        eventData = data
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        
        if textLabel.font != FontVariables.eventLabelFont {
            textLabel.font = FontVariables.eventLabelFont
        }
        if textLabel.textColor != FontVariables.eventLabelTextColor {
            textLabel.textColor = FontVariables.eventLabelTextColor
        }
        if textLabel.minimumScaleFactor != FontVariables.eventLabelMinimumScale {
            textLabel.minimumScaleFactor = FontVariables.eventLabelMinimumScale
        }
    }
    
    func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.eventViewWasTapped(self)
    }
    
    private func setView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: NibNames.eventView, bundle: bundle)
        self.view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        if view != nil {
            self.view!.frame = self.bounds
            self.view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.view!)
        }
        self.backgroundColor = UIColor.clear
        self.view?.backgroundColor = eventData.color
        
        textLabel.text = eventData.title
        textLabel.font = FontVariables.eventLabelFont
        textLabel.minimumScaleFactor = LayoutDefaults.eventLabelMinimumScale
        textLabel.adjustsFontSizeToFitWidth = true
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }

}

protocol EventViewDelegate: class {
    
    func eventViewWasTapped(_ eventView: EventView)

}
