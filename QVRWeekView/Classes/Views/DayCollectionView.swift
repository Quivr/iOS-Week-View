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
        self.decelerationRate = UIScrollViewDecelerationRateFast
    }
}

// MARK: - DAY COLLECTION VIEW FLOW LAYOUT -

class DayCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private let layoutVariables: LayoutVariables
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(layoutVariables: LayoutVariables) {
        self.layoutVariables = layoutVariables
        super.init()
        self.itemSize = CGSize(width: layoutVariables.dayViewCellWidth, height: layoutVariables.dayViewCellHeight)
        self.minimumLineSpacing = layoutVariables.dayViewHorizontalSpacing
        self.scrollDirection = .horizontal
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let totalDayViewWidth = layoutVariables.totalDayViewCellWidth
        let xOffset = proposedContentOffset.x
        let xVelocity = velocity.x

        let cellOffset = round(xOffset / totalDayViewWidth)
        let velocityOffset = round(xVelocity * layoutVariables.velocityOffsetMultiplier)

        if velocityOffset != 0 {
            let targetXOffset = ((cellOffset + velocityOffset)*totalDayViewWidth).roundUpAdditionalHalf()
            return CGPoint(x: targetXOffset, y: proposedContentOffset.y)
        }
        else {
            return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y)
        }
    }

}
