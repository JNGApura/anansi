//
//  TimestampView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 23/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class TimestampView: RevealableView {
    
    let timestampIcon : UIImageView = {
        let i = UIImageView()
        i.tintColor = UIColor.secondary.withAlphaComponent(0.4)
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let timestamp : UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        l.textAlignment = .left
        l.numberOfLines = 0
        l.textColor = UIColor.secondary.withAlphaComponent(0.4)
        l.backgroundColor = .background
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(timestamp)
        addSubview(timestampIcon)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setConstraints(with hasReaction: Bool, and isIncoming: Bool) {
        
        // 16.0 - reactionStackView height
        let centerYConstant : CGFloat = hasReaction ? 16.0 : 0
        
        timestampIcon.image = isIncoming ? UIImage(named: "message-incoming")!.withRenderingMode(.alwaysTemplate) : UIImage(named: "message-outcoming")!.withRenderingMode(.alwaysTemplate)
        
        NSLayoutConstraint.activate([
            timestamp.leadingAnchor.constraint(equalTo: timestampIcon.trailingAnchor, constant: Const.marginEight),
            timestamp.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 1.5),
            timestamp.heightAnchor.constraint(equalToConstant: Const.marginEight * 2.0),
            timestamp.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -centerYConstant / 2.0),
            
            timestampIcon.centerYAnchor.constraint(equalTo: timestamp.centerYAnchor, constant: -1.0),
            timestampIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            timestampIcon.heightAnchor.constraint(equalTo: widthAnchor),
            timestampIcon.widthAnchor.constraint(equalToConstant: 14.0),
        ])
    }
}
