//
//  UICollectionView+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

extension UICollectionView {
    
    func scrollToBottom() {
        
        var indexPath: IndexPath?
        
        if self.numberOfSections > 1 {
            let lastSection = self.numberOfSections - 1
            indexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
        } else if numberOfItems(inSection: 0) > 0 && numberOfSections == 1 {
            indexPath = IndexPath(item: numberOfItems(inSection: 0) - 1, section: 0)
        }
        
        if let indexPath = indexPath {
            scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
}
