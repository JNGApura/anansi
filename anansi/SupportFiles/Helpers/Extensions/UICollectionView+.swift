//
//  UICollectionView+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func scrollToBottom(at position: UICollectionView.ScrollPosition) {
        
        var indexPath: IndexPath?
        
        if numberOfSections > 1 {
            let lastSection = numberOfSections - 1
            indexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
            
        } else if numberOfItems(inSection: 0) > 0 && numberOfSections == 1 {
            indexPath = IndexPath(item: numberOfItems(inSection: 0) - 1, section: 0)
        }
        
        if let indexPath = indexPath {
            scrollToItem(at: indexPath, at: position, animated: true)
        }
    }
}
