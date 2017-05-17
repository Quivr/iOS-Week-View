import Foundation
import UIKit

/**
 Class of the side bar hour label view contained within the CalendarView
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
    
    private func setView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: NibNames.hourSideBarView, bundle: bundle)
        self.view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        if view != nil {
            self.view!.frame = self.bounds
            self.view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.view!)
        }
        self.backgroundColor = UIColor.clear
    }

}
