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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init() {
        super.init()
        initialize()
    }

    private func initialize() {
        self.itemSize = CGSize(width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.dayViewCellHeight)
        self.minimumLineSpacing = LayoutVariables.dayViewHorizontalSpacing
        self.scrollDirection = .horizontal
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        let xOffset = proposedContentOffset.x
        let xVelocity = velocity.x

        let cellOffset = round(xOffset / totalDayViewWidth)
        let velocityOffset = round(xVelocity * LayoutVariables.velocityOffsetMultiplier)

        if velocityOffset != 0 {
            let targetXOffset = ((cellOffset + velocityOffset)*totalDayViewWidth).roundUpAdditionalHalf()
            return CGPoint(x: targetXOffset, y: proposedContentOffset.y)
        }
        else {
            return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y)
        }
    }
}
