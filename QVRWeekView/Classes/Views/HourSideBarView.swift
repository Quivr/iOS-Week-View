import Foundation
import UIKit

/**
 Class of the side bar hour label view contained within the WeekView
 */
@IBDesignable
class HourSideBarView : UIView {
    
    @IBOutlet var hourLabels: Array<UILabel>!
    var view:UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setView()
        view!.prepareForInterfaceBuilder()
    }
    
    override func layoutSubviews() {
        if hourLabels[0].font != LayoutVariables.hourLabelFont {
            for label in hourLabels {
                label.font = LayoutVariables.hourLabelFont
            }
        }
        if hourLabels[0].textColor != LayoutVariables.hourLabelTextColor {
            for label in hourLabels {
                label.textColor = LayoutVariables.hourLabelTextColor
            }
        }
        if hourLabels[0].minimumScaleFactor != LayoutVariables.hourLabelMinimumScale {
            for label in hourLabels {
                label.minimumScaleFactor = LayoutVariables.hourLabelMinimumScale
            }
        }
    }
    
    private func setView() {
        let bundle = Bundle(for: type(of: self))
        
        var nib: UINib!
        if #available(iOS 9.0, *){
            nib = UINib(nibName: NibNames.hourSideBarView, bundle: bundle)
        }
        else {
            nib = UINib(nibName: NibNames.constrainedHourSideBarView, bundle: bundle)
        }
        
        self.view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        if view != nil {
            self.view!.frame = self.bounds
            self.view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.view!)
        }
        self.backgroundColor = UIColor.clear
        
        for label in hourLabels {
            label.font = LayoutVariables.hourLabelFont
            label.textColor = LayoutVariables.hourLabelTextColor
            label.minimumScaleFactor = LayoutVariables.hourLabelMinimumScale
            label.adjustsFontSizeToFitWidth = true
        }
    }

}
