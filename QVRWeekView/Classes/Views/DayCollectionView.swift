//
//  DayCollectionView.swift
//  Pods
//
//  Created by Reinert Lemmens on 5/22/17.
//
//

import UIKit

// MARK: - DAY COLLECTION VIEW -

class DayCollectionView: UICollectionView {
    // MARK: - INITIALIZERS & OVERRIDES -

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }

    private func initialize() {
        self.backgroundColor = UIColor.clear
        self.register(DayViewCell.self, forCellWithReuseIdentifier: CellKeys.dayViewCell)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
    }
}

// MARK: - DAY COLLECTION VIEW FLOW LAYOUT -

class DayCollectionViewFlowLayout: UICollectionViewFlowLayout {

    var velocityMultiplier: CGFloat = LayoutDefaults.velocityOffsetMultiplier

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init() {
        super.init()
        initialize()
    }

    private func initialize() {
        self.scrollDirection = .horizontal
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let xOffset = proposedContentOffset.x
        let xVelocity = velocity.x

        let cellOffset = round(xOffset / self.itemSize.width)
        let velocityOffset = round(xVelocity * self.velocityMultiplier)

        if velocityOffset != 0 {
            let targetXOffset = ((cellOffset + velocityOffset) * self.itemSize.width).roundUpAdditionalHalf()
            return CGPoint(x: targetXOffset, y: proposedContentOffset.y)
        }
        else {
            return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y)
        }
    }
}
