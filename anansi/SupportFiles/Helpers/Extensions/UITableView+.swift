//
//  UITableView+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class UIDynamicTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height)
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
