//
//  ChatHeaderView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class ChatHeaderView: UICollectionReusableView {
    
    var textLabel : UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = UIColor.secondary.withAlphaComponent(0.5)
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(withLabel label: String) {
        textLabel.text = label
    }
        
}
