//
//  TopTabCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 23/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class TopTabCell: UICollectionViewCell {
    
    let tabTitle: UILabel = {
        let u = UILabel()
        u.textColor = .secondary
        u.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        u.textAlignment = .center
        u.translatesAutoresizingMaskIntoConstraints = false
        return u
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tabTitle)
        NSLayoutConstraint.activate([
            tabTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabTitle.widthAnchor.constraint(equalTo: widthAnchor),
            tabTitle.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            tabTitle.textColor = isHighlighted ? .primary : .secondary
        }
    }
    
    override var isSelected: Bool {
        didSet {
            tabTitle.textColor = isSelected ? .primary : .secondary
        }
    }
    
}
