//
//  InterestCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class InterestCell : UICollectionViewCell {
    
    // MARK: Custom initializers
    
    var text : String? {
        didSet {
            titleLabel.text = text
        }
    }
    
    private var interestSelected : Bool = true
    
    lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        tl.textAlignment = .center
        tl.layer.cornerRadius = 4
        tl.layer.borderWidth = 1.5
        tl.layer.masksToBounds = true
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isInterestSelected() -> Bool {
        return interestSelected
    }
    
    func unselect() {
        self.interestSelected = false
        
        titleLabel.textColor = .secondary
        titleLabel.backgroundColor = .background
        titleLabel.layer.borderColor = UIColor.secondary.cgColor
    }
    
    func select() {
        self.interestSelected = true
        
        titleLabel.textColor = .background
        titleLabel.backgroundColor = .primary
        titleLabel.layer.borderColor = UIColor.primary.cgColor
    }
}
