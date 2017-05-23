import Foundation
import UIKit

/**
 Class of the day view columns generated and displayed within DayScrollView
 */
class DayViewCell : UICollectionViewCell {
    
    @IBOutlet var seperators:[UIView]!
    @IBOutlet var overlayView:UIView!
    @IBOutlet var hourIndicatorView:UIView!
    @IBOutlet var overlayBottomConstraint:NSLayoutConstraint!
    
    var view:UIView?
    
    private var bottomDistancePercent = CGFloat(0)
    private var bottomAdjustmentBuffer = CGFloat(0)
    private var dottedSeperators:[CAShapeLayer] = []
    private(set) var date:Date!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    override func layoutSubviews() {
        
        // If main view is nil do not render anything
        guard view != nil else {
            return
        }
        
        // Clear old seperators
        for layer in dottedSeperators {
            layer.removeFromSuperlayer()
        }
        dottedSeperators = []
        
        // Generate dotted line seperators
        for i in 0...23 {
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath()
            
            let cellHeight = self.frame.height/24
            let y1 = cellHeight*CGFloat(i) + cellHeight/2
            
            path.move(to: CGPoint(x: 0, y: y1))
            path.addLine(to: CGPoint(x: self.frame.width, y: y1))
            
            shapeLayer.path=path.cgPath
            shapeLayer.lineDashPattern = [3,1]
            shapeLayer.lineWidth = seperators[0].frame.height
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.opacity = 1.0
            shapeLayer.strokeColor = LayoutDefaults.backgroundGray.cgColor
            
            if let mainView = view {
                dottedSeperators.append(shapeLayer)
                mainView.layer.insertSublayer(shapeLayer, below: overlayView.layer)
            }
        }

    }
    
    func setDate(`as` date:Date) {
        self.date = date
        
        if date.hasPassed() {
            overlayView.isHidden = false
            overlayView.backgroundColor = LayoutDefaults.overlayColor
            
            // If is today
            if date.isToday() {
                bottomDistancePercent = date.getPercentDayPassed()
                bottomAdjustmentBuffer = -1.5
                hourIndicatorView.isHidden = false
                hourIndicatorView.backgroundColor = LayoutDefaults.overlayIndicatorColor
            }
            else {
                bottomDistancePercent = 0.0
                bottomAdjustmentBuffer = 0.0
                hourIndicatorView.isHidden = true
            }
            updateBottomOverlayConstraint()
        }
        else {
            overlayView.isHidden = true
        }
        
        if date.isWeekend() {
            self.view!.backgroundColor = LayoutDefaults.weekendDayViewColor
        }
        else {
            self.view!.backgroundColor = LayoutDefaults.defaultDayViewColor
        }
    }
    
    func updateBottomOverlayConstraint() {
        overlayBottomConstraint.constant = self.frame.height*bottomDistancePercent + bottomAdjustmentBuffer
    }
    
    private func setView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: NibNames.dayView, bundle: bundle)
        self.view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        if view != nil {
            self.view!.frame = self.bounds
            self.view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view!.backgroundColor = LayoutDefaults.defaultDayViewColor
            self.addSubview(self.view!)
        }
        self.backgroundColor = UIColor.clear
        
        for sep in seperators {
            sep.backgroundColor = LayoutDefaults.backgroundGray
        }
    }
}
