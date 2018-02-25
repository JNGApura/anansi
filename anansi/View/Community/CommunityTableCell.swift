//
//  CommunityTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class CommunityTableCell: UITableViewCell {

    // MARK: Custom initializers
    var dictionary: [String: Any]! {
        didSet {
            self.name.text = dictionary["name"] as? String
            self.field.text = dictionary["field"] as? String
            
            if let profileImageURL = dictionary["profileImageURL"] as? String {
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
            } else {
                self.profileImageView.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 80 / 2 //28.0
        i.layer.masksToBounds = true
        return i
    }()
    
    let name: UILabel = {
        let tl = UILabel()
        tl.text = "name"
        tl.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let field: UILabel = {
        let tl = UILabel()
        tl.text = "field or occupation"
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [profileImageView, name, field].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80.0),
            profileImageView.heightAnchor.constraint(equalToConstant: 80.0),
            
            name.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 2.0 - 2.0),
            name.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            name.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            field.topAnchor.constraint(equalTo: name.bottomAnchor, constant: Const.marginEight / 2.0),
            field.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("it was clever to put this here. prepareForReuse @ community was just used")
        
        self.name.text = dictionary["name"] as? String
        self.field.text = dictionary["field"] as? String
        
        if let profileImageURL = dictionary["profileImageURL"] as? String {
            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
        } else {
            self.profileImageView.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
        }
    }
}
