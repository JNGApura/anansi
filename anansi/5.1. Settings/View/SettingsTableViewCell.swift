//
//  SettingsTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    let itemTitle : UILabel = {
        let l = UILabel()
        l.text = "Title"
        l.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let itemSubtitle : UILabel = {
        let l = UILabel()
        l.text = "Subtitle"
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let itemIcon : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.backgroundColor = .clear
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let itemArrow : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "itemArrow")?.withRenderingMode(.alwaysTemplate)
        i.contentMode = .scaleAspectFill
        i.backgroundColor = .clear
        i.tintColor = .tertiary
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var itemStackView : UIStackView = {
        let sv = UIStackView(arrangedSubviews: [itemTitle, itemSubtitle])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [itemIcon, itemStackView, itemArrow].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            itemIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            itemIcon.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
            itemIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0),
            itemIcon.heightAnchor.constraint(equalToConstant: 32.0),
            itemIcon.widthAnchor.constraint(equalToConstant: 32.0),
            
            itemStackView.leadingAnchor.constraint(equalTo: itemIcon.trailingAnchor, constant: Const.marginEight * 2.0),
            itemStackView.trailingAnchor.constraint(equalTo: itemArrow.leadingAnchor, constant: -Const.marginEight * 2.0),
            itemStackView.centerYAnchor.constraint(equalTo: itemIcon.centerYAnchor),
            
            itemArrow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            itemArrow.centerYAnchor.constraint(equalTo: itemIcon.centerYAnchor),
            itemArrow.heightAnchor.constraint(equalToConstant: 32.0),
            itemArrow.widthAnchor.constraint(equalToConstant: 32.0),
            
        ])
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        itemTitle.text = "Title"
        
        itemSubtitle.text = "Subtitle"
        
        itemIcon.image = UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)
                
    }
    
}
