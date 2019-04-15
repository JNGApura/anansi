//
//  ScheduleTalkTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class ScheduleTalkTableViewCell: UITableViewCell {
    
    let card : UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.layer.cornerRadius = 8.0
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let cardTitle : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let cardDescription : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 0, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let cardLocation : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .primary
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let speakerPic : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.isHidden = true
        i.backgroundColor = .clear
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [card, cardTitle, cardDescription, cardLocation, speakerPic].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6.0),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6.0),
            
            cardTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: Const.marginEight * 2.0),
            cardTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardTitle.trailingAnchor.constraint(equalTo: speakerPic.leadingAnchor, constant: -Const.marginEight * 2.0),
            
            cardDescription.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: Const.marginEight),
            cardDescription.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardDescription.trailingAnchor.constraint(equalTo: speakerPic.leadingAnchor, constant: -Const.marginEight * 2.0),
            
            cardLocation.topAnchor.constraint(equalTo: cardDescription.bottomAnchor, constant: Const.marginEight * 2.0),
            cardLocation.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardLocation.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Const.marginEight * 2.0),
            cardLocation.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Const.marginEight * 2.0),
            
            speakerPic.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: 0.0),
            speakerPic.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: 0.0),
            speakerPic.heightAnchor.constraint(equalToConstant: 128.0),
            speakerPic.widthAnchor.constraint(equalToConstant: 128.0),
            speakerPic.widthAnchor.constraint(lessThanOrEqualTo: card.heightAnchor, constant: 1.0)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        cardTitle.text = "Title"
        
        cardDescription.text = "Description"
        
        cardLocation.text = "Location"
        
        speakerPic.isHidden = true
        
        card.backgroundColor = .tertiary
    }
    
}
