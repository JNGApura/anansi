//
//  SearchTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 11/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class SearchTableCell: UITableViewCell {

    // MARK: Custom initializers
    var profileImageURL : String! {
        didSet {
            profileImageView.setImage(with: profileImageURL)
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 20
        i.layer.masksToBounds = true
        i.clipsToBounds = true
        return i
    }()
    
    let name: UILabel = {
        let tl = UILabel()
        tl.text = ""
        tl.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let interestsInCommon: UILabel = {
        let tl = UILabel()
        tl.text = ""
        tl.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        tl.textColor = .secondary
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    lazy var stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [name, interestsInCommon].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSpacing(2.0, after: name)
        
        [profileImageView, stackView].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40.0),
            profileImageView.heightAnchor.constraint(equalToConstant: 40.0),
            
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.name.text = ""
        self.interestsInCommon.text = ""
        
        self.profileImageView.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
    }
}
