//
//  ScheduleTalkTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class ScheduleTalkTableViewCell: UITableViewCell {
    
    var type : String? {
        didSet {
            type == "talk" ? (card.image = UIImage(named: "speakerCard")!.withRenderingMode(.alwaysOriginal)) : (card.image = UIImage(named: "activityCard")!.withRenderingMode(.alwaysOriginal))
        }
    }
    
    let card : UIImageView = { // hack
        let i = UIImageView()
        //i.image = UIImage(named: "speakerCard")!.withRenderingMode(.alwaysOriginal)
        i.contentMode = .scaleToFill
        i.layer.cornerRadius = 8.0
        i.clipsToBounds = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
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
        i.contentMode = .scaleAspectFit
        i.isHidden = true
        i.backgroundColor = .clear
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        [card, cardTitle, cardDescription, cardLocation, speakerPic].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6.0),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6.0),
            
            cardTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: Const.marginEight * 2.0),
            cardTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardTitle.trailingAnchor.constraint(equalTo: speakerPic.leadingAnchor, constant: -Const.marginEight * 2.0),
            cardTitle.heightAnchor.constraint(equalToConstant: 20.0),
            
            cardDescription.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: Const.marginEight),
            cardDescription.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardDescription.trailingAnchor.constraint(equalTo: speakerPic.leadingAnchor, constant: -Const.marginEight * 2.0),
            cardDescription.bottomAnchor.constraint(lessThanOrEqualTo: cardLocation.topAnchor, constant: -Const.marginEight),
                        
            cardLocation.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Const.marginEight * 2.0),
            cardLocation.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardLocation.trailingAnchor.constraint(equalTo: speakerPic.leadingAnchor, constant: -Const.marginEight * 2.0),
            
            speakerPic.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            speakerPic.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            speakerPic.widthAnchor.constraint(equalToConstant: 128.0),
            speakerPic.heightAnchor.constraint(lessThanOrEqualToConstant: 128.0)
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
    }
}
