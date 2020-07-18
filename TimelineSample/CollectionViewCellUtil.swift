//
//  CollectionViewCellUtil.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/18.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCellUtil {
    static let shared = CollectionViewCellUtil()
    
    func calculateCellNowBounds(collectionView: UICollectionView, cell: UICollectionViewCell) -> CGRect {
        let point = CGPoint(x: cell.frame.origin.x - collectionView.contentOffset.x,
                            y: cell.frame.origin.y - collectionView.contentOffset.y)
        let size = cell.bounds.size
        return CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
    }
}
