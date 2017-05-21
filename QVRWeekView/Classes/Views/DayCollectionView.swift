//
//  DayCollectionView.swift
//  Pods
//
//  Created by Reinert Lemmens on 5/22/17.
//
//

import UIKit

class DayCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    let cellWidth = CGFloat(150)
    let sideSpacing = CGFloat(10)
    private var didJustCrossBorder: Bool = false
    
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
        self.dataSource = self
        self.delegate = self
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture)))
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 {
            print("crossed")
            didJustCrossBorder = true
            scrollView.contentOffset.x = 640
        }
        else if scrollView.contentOffset.x > 1120 {
            print("crossed")
            didJustCrossBorder = true
            scrollView.contentOffset.x = 640
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if didJustCrossBorder && !decelerate {
            let targetOffset = round(scrollView.contentOffset.x/(cellWidth+sideSpacing))*(cellWidth+sideSpacing)
            scrollView.setContentOffset(CGPoint(x: targetOffset, y: scrollView.contentOffset.y), animated: true)
            didJustCrossBorder = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if didJustCrossBorder {
            let targetOffset = round(scrollView.contentOffset.x/(cellWidth+sideSpacing))*(cellWidth+sideSpacing)
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
    
    func pinchGesture() {
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 150, height: 500)
    }


}

class DayCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let cellWidth = CGFloat(150)
    let sideSpacing = CGFloat(10)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init() {
        super.init()
        initialize()
    }
    
    func initialize() {
        self.itemSize = CGSize(width: cellWidth, height: 950)
        self.minimumInteritemSpacing = sideSpacing
        self.minimumLineSpacing = 10.0
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var targetCell = round(proposedContentOffset.x/(cellWidth+sideSpacing))
        targetCell = round(targetCell + velocity.x)
        let targetOffset = targetCell*(cellWidth+sideSpacing)
        
        return CGPoint(x: targetOffset, y: proposedContentOffset.y)
        
    }
    
}
