//
//  DescriptionTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    let itemDescription : UILabel = {
        let l = UILabel()
        l.text = "Description"
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [itemDescription].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            itemDescription.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            itemDescription.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            itemDescription.topAnchor.constraint(equalTo: topAnchor),
            itemDescription.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        itemDescription.text = "Description"
    }
}
