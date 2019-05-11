//
//  ContactInfoTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class ContactInfoTableViewCell: UITableViewCell {

    let itemTitle : UILabel = {
        let l = UILabel()
        l.text = "Title"
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var itemIcon : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.backgroundColor = .tertiary
        i.tintColor = .secondary
        i.layer.cornerRadius = 16.0
        i.clipsToBounds = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [itemIcon, itemTitle].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            itemIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            itemIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            itemIcon.heightAnchor.constraint(equalToConstant: 32.0),
            itemIcon.widthAnchor.constraint(equalToConstant: 32.0),
            
            itemTitle.leadingAnchor.constraint(equalTo: itemIcon.trailingAnchor, constant: Const.marginEight * 2.0),
            itemTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            itemTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        itemTitle.text = "Title"
        itemIcon.image = nil
        
    }
}
