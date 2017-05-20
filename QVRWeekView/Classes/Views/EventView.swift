//
//  EventView.swift
//  ProjectCalendar
//
//  Created by Reinert Lemmens on 5/14/17.
//  Copyright © 2017 lemonrainn. All rights reserved.
//

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
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setView()
        view!.prepareForInterfaceBuilder()
    }

    override func layoutSubviews() {
        textLabel.font = UIFont.boldSystemFont(ofSize: LayoutDefaults.eventLabelFontSize)
        textLabel.minimumScaleFactor = LayoutDefaults.eventLabelMinimumScale
        textLabel.adjustsFontSizeToFitWidth = true
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
        
    }

}
