//
//  ChatCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatCell: UITableViewCell {
    
    let myID = NetworkManager.shared.getUID()
    let badgeRadius : CGFloat = 9.0
    
    var message : Message? {
        didSet {
            
            if let id = message?.partnerID() {
                
                NetworkManager.shared.fetchUser(userID: id) { (dictionary) in
                    
                    let user = User()
                    user.set(dictionary: dictionary, id: id)
                    
                    self.name.text = user.getValue(forField: .name) as? String
                    
                    if let imageURL = (user.getValue(forField: .profileImageURL) as? String) {
                        self.profileImageView.setImage(with: imageURL)
                    } else {
                        self.profileImageView.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
                    }
                    
                    if let isTyping = dictionary["isTypingTo"] as? String, isTyping == self.myID! {
                        self.lastMessage.text = "is typing..."
                        
                    } else {
                        var displayMessage: String = ""
                        
                        if let sender = self.message?.sender, sender == self.myID { displayMessage += "You: " }
                        if let message = self.message!.text { displayMessage += message }
                        
                        self.lastMessage.text = displayMessage
                    }
                    
                    if let seconds = self.message?.timestamp?.doubleValue {
                        
                        let timestampDate = NSDate(timeIntervalSince1970: seconds)
                        self.timeLabel.text = createTimeString(date: timestampDate)
                    }
                }
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 64.0 / 2
        i.layer.masksToBounds = true
        return i
    }()
    
    lazy var badge : Badge = {
        let b = Badge(frame: CGRect(x: 0, y: 0, width: badgeRadius * 2, height: badgeRadius * 2), innerColor: .primary, outerColor: .background, innerRadius: 6)
        b.isHidden = true
        return b
    }()
    
    let name: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let lastMessage: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = UIColor.secondary.withAlphaComponent(0.4)
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.lineBreakMode = .byTruncatingTail
        tl.numberOfLines = 0
        return tl
    }()
    
    let topStackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.textColor = .secondary
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [name, timeLabel].forEach { topStackView.addArrangedSubview($0) }
        topStackView.setCustomSpacing(Const.marginSafeArea, after: name)
        
        [topStackView, lastMessage].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSpacing(Const.marginEight / 2.0, after: topStackView)
        
        [profileImageView, badge, stackView, timeLabel, separator].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight*2),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 64.0),
            profileImageView.heightAnchor.constraint(equalToConstant: 64.0),
            
            topStackView.heightAnchor.constraint(equalToConstant: 24.0),
            
            timeLabel.trailingAnchor.constraint(equalTo: topStackView.trailingAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: name.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 80.0),
            
            stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            
            lastMessage.heightAnchor.constraint(equalToConstant: 24.0),

            separator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Is this necessary?
        badge.frame = CGRect(x: profileImageView.frame.maxX - badgeRadius, y: profileImageView.frame.midY - badgeRadius, width: badgeRadius * 2, height: badgeRadius * 2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        name.text = ""
        lastMessage.text = ""
        timeLabel.text = ""
        profileImageView.image = nil
        
    }
}
