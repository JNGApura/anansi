//
//  PageSelectorCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 23/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class PageSelectorCell: UICollectionViewCell {
    
    let tabBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.layer.cornerRadius = 4.0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let tabIcon: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "Settings")?.withRenderingMode(.alwaysTemplate)
        i.tintColor = .secondary
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
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
        
        addSubview(tabBackground)
        addSubview(tabIcon)
        addSubview(tabTitle)
        
        NSLayoutConstraint.activate([
            
            tabBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabBackground.widthAnchor.constraint(equalTo: widthAnchor),
            tabBackground.heightAnchor.constraint(equalTo: heightAnchor),
            
            tabIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            tabIcon.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            tabIcon.bottomAnchor.constraint(equalTo: topAnchor, constant: -8.0),
            tabIcon.widthAnchor.constraint(equalToConstant: 21.0),
            
            tabTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabTitle.leadingAnchor.constraint(equalTo: tabIcon.trailingAnchor, constant: 10.0),
            tabTitle.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tabIcon.image = UIImage(named: "Profile")?.withRenderingMode(.alwaysTemplate)
        tabTitle.text = ""
    }
    
    override var isHighlighted: Bool {
        didSet {
            tabBackground.backgroundColor = isHighlighted ? .primary : .tertiary
            tabIcon.tintColor = isHighlighted ? .background : .secondary
            tabTitle.textColor = isHighlighted ? .background : .secondary
        }
    }
    
    override var isSelected: Bool {
        didSet {
            tabBackground.backgroundColor = isSelected ? .primary : .tertiary
            tabIcon.tintColor = isSelected ? .background : .secondary
            tabTitle.textColor = isSelected ? .background : .secondary
        }
    }
    
}
