//
//  UserTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class UserTableCell: UITableViewCell {

    // MARK: Custom initializers
    
    var user : User? {
        didSet {
            
            if let profileImageURL = user?.profileImageURL {
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
            } else {
                self.profileImageView.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
            }
            
            self.name.text = user?.name
            
            self.occupation.text = user?.occupation
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 28.0
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let name: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()

    let occupation: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [profileImageView, name, occupation].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 56.0),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            name.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 2.0 - 2.0),
            name.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            name.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            occupation.topAnchor.constraint(equalTo: name.bottomAnchor, constant: Const.marginEight / 2.0),
            occupation.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            occupation.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
