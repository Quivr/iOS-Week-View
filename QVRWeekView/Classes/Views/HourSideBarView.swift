import Foundation
import UIKit

/**
 Class of the side bar hour label view contained within the WeekView
 */
@IBDesignable
class HourSideBarView: UIView {

    // MARK: - INSTANCE VARIABLES -

    @IBOutlet var hourLabels: [HourLabel]!
    var view: UIView?

    // MARK: - CUSTOMIZATION VARIABLES -

    /**
     Font for all hour labels contained in the side bar.
     */
    var hourLabelFont: UIFont = LayoutDefaults.hourLabelFont {
        didSet {
            self.layoutIfNeeded()
        }
    }

    /**
     Text color for all hour labels contained in the side bar.
     */
    var hourLabelTextColor: UIColor = LayoutDefaults.hourLabelTextColor {
        didSet {
            self.layoutIfNeeded()
        }
    }

    /**
     Minimum percentage that hour label text will be resized to if label is too small.
     */
    var hourLabelMinimumFontSize: CGFloat = LayoutDefaults.hourLabelMinimumFontSize {
        didSet {
            self.layoutIfNeeded()
        }
    }

    /**
     Format of all hour labels.
     */
    var hourLabelDateFormat: String = LayoutDefaults.hourLabelDateFormat {
        didSet {
            self.layoutIfNeeded()
        }
    }

    private var hourLabelMinimumScale: CGFloat {
        return self.hourLabelMinimumFontSize / self.hourLabelFont.pointSize
    }

    // MARK: - FUNCTIONS -

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
        if hourLabels[0].font != self.hourLabelFont {
            for label in hourLabels {
                label.font = self.hourLabelFont
            }
        }
        if hourLabels[0].textColor != self.hourLabelTextColor {
            for label in hourLabels {
                label.textColor = self.hourLabelTextColor
            }
        }
        if hourLabels[0].minimumScaleFactor != self.hourLabelMinimumScale {
            for label in hourLabels {
                label.minimumScaleFactor = self.hourLabelMinimumScale
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
        df.dateFormat = self.hourLabelDateFormat
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
            label.font = self.hourLabelFont
            label.textColor = self.hourLabelTextColor
            label.minimumScaleFactor = self.hourLabelMinimumScale
            label.numberOfLines = 2
            label.adjustsFontSizeToFitWidth = true
        }
    }

}
