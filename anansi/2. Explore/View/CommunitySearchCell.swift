//
//  CommunitySearchCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class CommunitySearchCell: UITableViewCell {

    // MARK: Custom initializers
    
    let searchBar: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8.0
        v.clipsToBounds = true
        v.backgroundColor = UIColor.tertiary.withAlphaComponent(0.4)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let searchIcon: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "search")!.withRenderingMode(.alwaysTemplate)
        i.tintColor = UIColor.secondary.withAlphaComponent(0.6)
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let searchLabel: UILabel = {
        let tl = UILabel()
        tl.text = "Search for attendees"
        tl.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        tl.textColor = UIColor.secondary.withAlphaComponent(0.6)
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        [searchBar, searchIcon, searchLabel].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Const.marginEight),
            searchBar.heightAnchor.constraint(equalToConstant: 36.0),
            
            searchIcon.centerXAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: Const.marginEight * 2.0),
            searchIcon.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchIcon.heightAnchor.constraint(equalToConstant: 14.0),
            searchIcon.widthAnchor.constraint(equalToConstant: 14.0),
            
            searchLabel.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: Const.marginEight),
            searchLabel.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchLabel.heightAnchor.constraint(equalTo: searchBar.heightAnchor),
            searchLabel.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -Const.marginEight),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
