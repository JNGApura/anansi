//
//  ChatTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatTableCell: UITableViewCell {
    
    let myID = NetworkManager.shared.getUID()
    let badgeRadius : CGFloat = 9.0
    
    var message : Message? {
        didSet {
            
            if let partnerID = message?.partnerID() {
                
                NetworkManager.shared.fetchUser(userID: partnerID) { (dictionary) in
                    
                    // Fetches user
                    let user = User()
                    user.set(dictionary: dictionary, id: partnerID)
                    
                    // User name
                    self.name.text = user.getValue(forField: .name) as? String
                    
                    // Sets user's profile image
                    if let imageURL = (user.getValue(forField: .profileImageURL) as? String) {
                        self.profileImageView.setImage(with: imageURL)
                        self.hasReadImage.setImage(with: imageURL)
                    } else {
                        self.profileImageView.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
                        self.hasReadImage.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
                    }
                    
                    // Sets message box
                    if let isTyping = dictionary["isTypingTo"] as? String, isTyping == self.myID! {
                        self.lastMessage.text = "is typing..."
                        
                    } else {
                        
                        var displayMessage: String = ""
                        
                        // Sender
                        if let sender = self.message?.getValue(forField: .sender) as? String, sender == self.myID {
                            
                            displayMessage += "You: "
                            
                            // If chatPartner has seen my message, I display his/her profile picture in a small icon
                            if let isRead = self.message?.getValue(forField: .isRead) as? Bool, isRead {
                                self.hasReadImage.isHidden = false
                            } else {
                                self.hasReadImage.isHidden = true
                            }
                        }
                        
                        // Message
                        if let message = self.message!.getValue(forField: .text) as? String { displayMessage += message }
                        
                        self.lastMessage.text = displayMessage
                        self.lastMessage.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
                    }
                    
                    // Sets timestamp
                    if let seconds = (self.message?.getValue(forField: .timestamp) as? NSNumber)?.doubleValue {
                        self.timeLabel.text = " · " + createDateIntervalString(from: NSDate(timeIntervalSince1970: seconds))
                    }
                }
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 60.0 / 2
        i.layer.masksToBounds = true
        i.clipsToBounds = true
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
        tl.textColor = UIColor.secondary.withAlphaComponent(0.4)
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.lineBreakMode = .byTruncatingTail
        return tl
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.textColor = UIColor.secondary.withAlphaComponent(0.4)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let bottomStackView : UIStackView = {
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
    
    let hasReadImage: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 14.0 / 2
        i.layer.masksToBounds = true
        i.clipsToBounds = true
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        [lastMessage, timeLabel].forEach { bottomStackView.addArrangedSubview($0) }
        [name, bottomStackView].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSpacing(Const.marginEight / 4.0, after: name)
        
        [profileImageView, badge, stackView, hasReadImage, separator].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 1.5),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Const.marginEight * 1.5),
            profileImageView.widthAnchor.constraint(equalToConstant: 60.0),
            profileImageView.heightAnchor.constraint(equalToConstant: 60.0),
            
            name.heightAnchor.constraint(equalToConstant: 24.0),
            bottomStackView.heightAnchor.constraint(equalToConstant: 20.0),
            
            stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -42.0),
            
            hasReadImage.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            hasReadImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            hasReadImage.heightAnchor.constraint(equalToConstant: 14.0),
            hasReadImage.widthAnchor.constraint(equalToConstant: 14.0),
            
            separator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Is this necessary?
    override func layoutSubviews() {
        super.layoutSubviews()
        
        badge.frame = CGRect(x: profileImageView.frame.maxX - badgeRadius, y: profileImageView.frame.midY - badgeRadius, width: badgeRadius * 2, height: badgeRadius * 2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        name.text = ""
        lastMessage.text = ""
        timeLabel.text = ""
        profileImageView.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
        
    }
}
