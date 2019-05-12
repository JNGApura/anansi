//
//  InterestProfileEmptyTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 22/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class InterestProfileEmptyTableCell: UITableViewCell {
    
    lazy var myInterestsLabel : UILabel = {
        let l = UILabel()
        l.text = "My interests"
        l.textColor = UIColor.secondary.withAlphaComponent(0.75)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var CTALabel: UILabel = {
        let l = UILabel()
        l.text = "Pick topics you're interested in"
        l.textColor = UIColor.secondary.withAlphaComponent(0.2)
        l.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = .secondary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        addSubview(myInterestsLabel)
        addSubview(CTALabel)
        addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            
            myInterestsLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            myInterestsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            myInterestsLabel.widthAnchor.constraint(equalToConstant: 76.0),
            
            CTALabel.topAnchor.constraint(equalTo: myInterestsLabel.bottomAnchor, constant: 4.0),
            CTALabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            CTALabel.heightAnchor.constraint(equalToConstant: 26.0),
            CTALabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0),
            
            bottomLine.topAnchor.constraint(equalTo: CTALabel.bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
            bottomLine.heightAnchor.constraint(equalToConstant: 1.0),
        ])

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
