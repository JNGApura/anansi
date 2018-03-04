//
//  MessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessageCell: UITableViewCell {
    
    // REFACTOR MESSAGE: - prepare for reuse
    var message : Message? {
        didSet {
            
            var isTyping = false
            
            if let id = message?.messagePartnerID() {
                
                let ref = Database.database().reference().child("users").child(id)
                ref.observe(.value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: Any] {
                        
                        self.name.text = dictionary["email"] as? String
                        
                        if let profileImageURL = dictionary["profileImageURL"] as? String {
                            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
                        }
                        
                        if let newDic = dictionary["isSendingMessageTo"] as? [String: Any] {
                            if let messageIsBeingSentToMe = newDic[NetworkManager.shared.getUID()!] as? Bool {
                                isTyping = messageIsBeingSentToMe
                            }
                        }
                        
                        if isTyping {
                            self.lastMessage.text = "Typing..."
                            
                        } else {
                            
                            var displayMessage: String = ""
                            
                            if let sender = self.message?.sender, sender == NetworkManager.shared.getUID() {
                                displayMessage += "You: "
                            }
                            
                            if let message = self.message!.text {
                                displayMessage += message
                                
                            } else {
                                displayMessage += "Sent an image"
                            }
                            
                            self.lastMessage.text = displayMessage
                        }
                        
                        if let seconds = self.message?.timestamp?.doubleValue {
                            let timestampDate = NSDate(timeIntervalSince1970: seconds)
                            self.timeLabel.text = self.createTimeString(date: timestampDate)
                        }
                    }
                    
                }, withCancel: nil)
            }
        }
    }
    
    func createTimeString(date: NSDate) -> String {
        
        let formatter = DateFormatter()
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = NSCalendar.current.dateComponents([.month, .day], from: earliest as Date, to: latest as Date)
        
        if components.day! == 1 {
            return "yesterday"
            
        } else if components.day! < 1 {
            formatter.dateFormat = "hh:mm a"
            
        } else if components.day! > 1 && components.month! < 1 {
            formatter.dateFormat = "E"
            
        } else if components.month! >= 1 {
            formatter.dateFormat = "dd/MMM/yy"
        }
        
        return formatter.string(from: date as Date)
    }
    
    ////
    
    let profileImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = Const.exploreImageHeight / 2
        i.layer.masksToBounds = true
        return i
    }()
    
    let badgeRadius : CGFloat = 9.0
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
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.lineBreakMode = .byTruncatingTail
        tl.numberOfLines = 0
        return tl
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.textColor = .secondary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .secondary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [profileImageView, badge, name, lastMessage, timeLabel, separator].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight*2),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: Const.exploreImageHeight),
            profileImageView.heightAnchor.constraint(equalToConstant: Const.exploreImageHeight),
            
            name.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight*2),
            name.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
            name.heightAnchor.constraint(equalToConstant: Const.bodyFontSize + 2.0),
            
            lastMessage.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight*2),
            lastMessage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lastMessage.topAnchor.constraint(equalTo: name.bottomAnchor),
            lastMessage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0),
            
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 21.0),
            timeLabel.centerYAnchor.constraint(equalTo: name.centerYAnchor),
            timeLabel.heightAnchor.constraint(equalTo: name.heightAnchor),
            
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separator.widthAnchor.constraint(equalToConstant: 100),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(timeLabel.frame.width + 24)),
        ])
        
        badge.frame = CGRect(x: profileImageView.frame.maxX - badgeRadius, y: profileImageView.frame.midY - badgeRadius, width: badgeRadius * 2, height: badgeRadius * 2)
    }
}
