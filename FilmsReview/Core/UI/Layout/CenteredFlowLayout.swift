//
//  CenteredFlowLayout.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import UIKit

final class CenteredFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var rows: [[UICollectionViewLayoutAttributes]] = []
        var currentRowY: CGFloat = .greatestFiniteMagnitude
        
        for attr in attrs where attr.representedElementCategory == .cell {
            let isNewRow = abs(attr.frame.origin.y - currentRowY) > 1
            if isNewRow {
                rows.append([])
                currentRowY = attr.frame.origin.y
            }
            rows[rows.count - 1].append(attr.copy() as! UICollectionViewLayoutAttributes)
        }
        rows.forEach { centerRow($0) }
        
        let nonCells = attrs.filter { $0.representedElementCategory != .cell }
        return rows.flatMap { $0 } + nonCells
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
    
    private func centerRow(_ row: [UICollectionViewLayoutAttributes]) {
        guard
            let cv = collectionView,
            !row.isEmpty
        else { return }
        
        let contentWidth = cv.bounds.width - cv.contentInset.left - cv.contentInset.right
        let itemsWidth = row.reduce(CGFloat(0)) { $0 + $1.frame.width }
        let gaps = CGFloat(max(row.count - 1, 0))
        let totalSpacing = gaps * minimumInteritemSpacing
        let startX = max((contentWidth - itemsWidth - totalSpacing) / 2, 0)
        
        var x = startX
        for attr in row {
            var f = attr.frame
            f.origin.x = x
            attr.frame = f
            x += f.width + minimumInteritemSpacing
        }
    }
}
