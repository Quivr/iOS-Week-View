import Foundation
import UIKit

/**
 Class of the side bar hour label view contained within the WeekView
 */
@IBDesignable
class HourSideBarView: UIView {

    @IBOutlet var hourLabels: [HourLabel]!
    var view: UIView?

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
        updateLabels()
        view!.prepareForInterfaceBuilder()
    }

    override func layoutSubviews() {
        if hourLabels[0].font != TextVariables.hourLabelFont {
            for label in hourLabels {
                label.font = TextVariables.hourLabelFont
            }
        }
        if hourLabels[0].textColor != TextVariables.hourLabelTextColor {
            for label in hourLabels {
                label.textColor = TextVariables.hourLabelTextColor
            }
        }
        if hourLabels[0].minimumScaleFactor != TextVariables.hourLabelMinimumScale {
            for label in hourLabels {
                label.minimumScaleFactor = TextVariables.hourLabelMinimumScale
            }
        }
        updateLabels()
    }

    func updateLabels () {
        hourLabels.sort { (label1, label2) -> Bool in
            return label1.order < label2.order
        }

        var date = DateSupport.getZeroDate()
        let df = DateFormatter()
        df.dateFormat = TextVariables.hourLabelDateFormat
        for label in hourLabels {
            label.text = df.string(from: date)
            date.add(hours: 1)
        }
    }

    private func setView() {
        let bundle = Bundle(for: type(of: self))
        self.view = UINib(nibName: NibNames.hourSideBarView, bundle: bundle)
            .instantiate(withOwner: self, options: nil).first as? UIView
        if view != nil {
            self.view!.frame = self.bounds
            self.view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(self.view!)
        }
        self.backgroundColor = UIColor.clear

        for label in hourLabels {
            label.font = TextVariables.hourLabelFont
            label.textColor = TextVariables.hourLabelTextColor
            label.minimumScaleFactor = TextVariables.hourLabelMinimumScale
            label.numberOfLines = 2
            label.adjustsFontSizeToFitWidth = true
        }
    }

}
