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

    // Font for all hour labels contained in the side bar.
    var hourLabelFont: UIFont = LayoutDefaults.hourLabelFont { didSet { self.updateLabels() } }
    // Text color for all hour labels contained in the side bar.
    var hourLabelTextColor: UIColor = LayoutDefaults.hourLabelTextColor { didSet { self.updateLabels() } }
    // Minimum percentage that hour label text will be resized to if label is too small.
    var hourLabelMinimumFontSize: CGFloat = LayoutDefaults.hourLabelMinimumFontSize { didSet { self.updateLabels() } }
    // Format of all hour labels.
    var hourLabelDateFormat: String = LayoutDefaults.hourLabelDateFormat { didSet { self.updateLabels() } }
    // Minimum scale
    private var hourLabelMinimumScale: CGFloat { self.hourLabelMinimumFontSize / self.hourLabelFont.pointSize }

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
        updateLabels()
    }

    func updateLabels () {
        hourLabels.sort { (label1, label2) -> Bool in
            return label1.order < label2.order
        }

        for label in hourLabels {
            label.font = self.hourLabelFont
            label.textColor = self.hourLabelTextColor
            label.minimumScaleFactor = self.hourLabelMinimumScale
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
