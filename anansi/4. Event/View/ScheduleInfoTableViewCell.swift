//
//  ScheduleInfoTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class ScheduleInfoTableViewCell: UITableViewCell {

    let card : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.tertiary.withAlphaComponent(0.5)
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
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        [card, cardTitle, cardDescription, cardLocation].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6.0),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6.0),
            
            cardTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: Const.marginEight * 2.0),
            cardTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            
            cardDescription.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: Const.marginEight),
            cardDescription.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardDescription.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            
            cardLocation.topAnchor.constraint(equalTo: cardDescription.bottomAnchor, constant: Const.marginEight * 2.0),
            cardLocation.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Const.marginEight * 2.0),
            cardLocation.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Const.marginEight * 2.0),
            cardLocation.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Const.marginEight * 2.0),

        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        cardTitle.text = "Title"
        
        cardDescription.text = "Description"
        
        cardLocation.text = "Location"
        
        card.backgroundColor = UIColor.tertiary.withAlphaComponent(0.5)
    }
    
}
