//
//  DayCollectionView.swift
//  Pods
//
//  Created by Reinert Lemmens on 5/22/17.
//
//

import UIKit

// MARK: - LAYOUT VARIABLES -

// MARK: - DAY COLLECTION VIEW -

class DayCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    private var didJustCrossBorder: Bool = false
    
    // MARK: - INITIALIZERS & OVERRIDES -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCollection()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initCollection()
    }
    
    private func initCollection() {
        
        self.backgroundColor = UIColor.clear
        self.register(DayView.self, forCellWithReuseIdentifier: "customCell")
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        
    }
    
    // MARK: - INTERNAL FUNCTIONS -

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 {
            didJustCrossBorder = true
            scrollView.contentOffset.x = 640
        }
        else if scrollView.contentOffset.x > 1120 {
            didJustCrossBorder = true
            scrollView.contentOffset.x = 640
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if didJustCrossBorder && !decelerate {
            
            let totalDayViewCellWidth = LayoutVariables.totalDayViewCellWidth
            let targetOffset = round(scrollView.contentOffset.x/totalDayViewCellWidth)*totalDayViewCellWidth
            scrollView.setContentOffset(CGPoint(x: targetOffset, y: scrollView.contentOffset.y), animated: true)
            didJustCrossBorder = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if didJustCrossBorder {
            
            let totalDayViewCellWidth = LayoutVariables.totalDayViewCellWidth
            let targetOffset = round(scrollView.contentOffset.x/totalDayViewCellWidth)*totalDayViewCellWidth
            scrollView.setContentOffset(CGPoint(x: targetOffset, y: scrollView.contentOffset.y), animated: true)
            didJustCrossBorder = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath)
    }
}

// MARK: - DAY COLLECTION VIEW

class DayCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init() {
        super.init()
        initialize()
    }
    
    func initialize() {
        self.itemSize = CGSize(width: LayoutVariables.dayViewCellWidth, height: LayoutVariables.dayViewCellHeight)
        self.minimumLineSpacing = LayoutVariables.dayViewHorizontalSpacing
        self.scrollDirection = .horizontal
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let totalDayViewWidth = LayoutVariables.totalDayViewCellWidth
        var targetCell = round(proposedContentOffset.x/totalDayViewWidth)
        targetCell = round(targetCell + velocity.x)
        let targetOffset = targetCell*totalDayViewWidth
        
        print(collectionViewContentSize)
        
        return CGPoint(x: targetOffset, y: proposedContentOffset.y)
        
    }
    
}
