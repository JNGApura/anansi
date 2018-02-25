//
//  UserCollectionCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class UserCollectionCell: UICollectionViewCell {
    
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
        imageView.layer.cornerRadius = 80 / 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let name: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .center
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let occupation: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .center
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [profileImageView, name, occupation].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 2.0),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80.0),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            name.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Const.marginEight * 0.5),
            name.leadingAnchor.constraint(equalTo: leadingAnchor),
            name.trailingAnchor.constraint(equalTo: trailingAnchor),
            name.widthAnchor.constraint(equalTo: widthAnchor),
            
            occupation.topAnchor.constraint(equalTo: name.bottomAnchor),
            occupation.leadingAnchor.constraint(equalTo: leadingAnchor),
            occupation.trailingAnchor.constraint(equalTo: trailingAnchor),
            occupation.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("it was clever to put this here. prepareForReuse @ community was just used")
        
        if let profileImageURL = user?.profileImageURL {
            
            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
        } else {
            
            self.profileImageView.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
        }
        
        self.name.text = user?.name
        
        self.occupation.text = user?.occupation
    }
}
