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
            
            if let profileImageURL = user?.getValue(forField: .profileImageURL) as? String {
                self.profileImageView.setImage(with: profileImageURL)
            } else {
                self.profileImageView.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            }
            
            if let name = user?.getValue(forField: .name) as? String { self.name.text = name }

            if let occupation = user?.getValue(forField: .occupation) as? String { self.occupation.text = occupation }
        }
    }
    
    let profileImageView: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 28.0
        i.layer.masksToBounds = true
        return i
    }()

    let name: UILabel = {
        let tl = UILabel()
        tl.text = "Name"
        tl.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        tl.textColor = .secondary
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()

    let occupation: UILabel = {
        let tl = UILabel()
        tl.text = ""
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    
    // Makes sure the cell is re-used and properly initialized
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.name.text = ""
        self.occupation.text = ""
        self.profileImageView.image = nil
    }

}
