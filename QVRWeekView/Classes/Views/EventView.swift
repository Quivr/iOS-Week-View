

import UIKit

class EventView: UIView {

    @IBOutlet var textLabel: UILabel!
    
    var view:UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    override func layoutSubviews() {
        
        if textLabel.font != LayoutVariables.eventLabelFont {
            textLabel.font = LayoutVariables.eventLabelFont
        }
        if textLabel.textColor != LayoutVariables.eventLabelTextColor {
            textLabel.textColor = LayoutVariables.eventLabelTextColor
        }
        if textLabel.minimumScaleFactor != LayoutVariables.eventLabelMinimumScale {
            textLabel.minimumScaleFactor = LayoutVariables.eventLabelMinimumScale
        }
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
        
        textLabel.font = LayoutVariables.eventLabelFont
        textLabel.minimumScaleFactor = LayoutDefaults.eventLabelMinimumScale
        textLabel.adjustsFontSizeToFitWidth = true
    }

}
