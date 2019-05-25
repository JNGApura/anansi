//
//  ChatMessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol CellGestureRecognizerDelegate: class {
    func singleTapDetected(in indexPath: IndexPath)
    func doubleTapDetected(in indexPath: IndexPath, with message: Message, and love: Bool)
    func longPressDetected(in indexPath: IndexPath, with message: Message, from sender: UILongPressGestureRecognizer)
}

class ChatMessageCell: UITableViewCell {
    
    // MARK: Custom initializers
    
    weak var gestureRecognizerDelegate: CellGestureRecognizerDelegate?
    
    var indexPath: IndexPath!
    var message: Message!
    var isIncoming: Bool!
    
    var isLoved: Bool = false
    
    // Love button
    lazy var loveButton : UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "heart-unfilled")!.withRenderingMode(.alwaysTemplate), for: .normal)
        b.imageView?.tintColor = .tertiary
        b.imageView?.contentMode = .scaleAspectFit
        b.imageEdgeInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0);
        b.addTarget(self, action: #selector(spreadLove), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // Love reaction
    let loveReaction : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "heart-filled")!.withRenderingMode(.alwaysTemplate)
        i.tintColor = .primary
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let badgeReaction : UIImageView = {
        let i = UIImageView()
        i.layer.cornerRadius = 16.0 / 2
        i.layer.masksToBounds = true
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let reactionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Message
    let msgtxt : UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        l.textAlignment = .left
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let bubble: UIView = {
        let bv = UIView()
        bv.layer.borderWidth = 2
        bv.layer.borderColor = UIColor.red.cgColor
        bv.layer.cornerRadius = 20
        bv.layer.masksToBounds = true
        bv.clipsToBounds = true
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    let msgstatus : UIImageView = {
        let i = UIImageView()
        i.layer.cornerRadius = 16.0 / 2
        i.layer.masksToBounds = true
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFit
        //i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let timestamp : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.textAlignment = .right
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let messageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // To be able to modify the constraints externally
    var bubbleTrailingAnchor: NSLayoutConstraint?
    var bubbleLeadingAnchor: NSLayoutConstraint?
    var bubbleViewHeightAnchor: NSLayoutConstraint?
    var messageLabelHeightAnchor: NSLayoutConstraint?
    
    // MARK: Cell init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // Fuck iPhone 5
        let maxWidth : CGFloat = Display.typeIsLike == .iphone5 ? 232.0 : 280.0
        
        // Add subviews
        [loveReaction, badgeReaction].forEach { reactionStackView.addArrangedSubview($0) }
        reactionStackView.setCustomSpacing(Const.marginEight * 0.5, after: loveReaction)
        
        [bubble, reactionStackView].forEach { messageStackView.addArrangedSubview($0) }
        messageStackView.setCustomSpacing(2.0, after: bubble)
        
        [messageStackView, msgtxt, loveButton, msgstatus].forEach { addSubview($0) }
    
        // Add layout constraints to subviews
        NSLayoutConstraint.activate([
            
            messageStackView.topAnchor.constraint(equalTo: topAnchor, constant: 3.0),
            messageStackView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            messageStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0),
            
            msgtxt.topAnchor.constraint(equalTo: bubble.topAnchor, constant: Const.marginEight),
            msgtxt.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -Const.marginEight),
            msgtxt.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: Const.marginEight * 2.0),
            msgtxt.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -Const.marginEight * 2.0),
            
            msgstatus.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight / 2.0),
            msgstatus.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
            msgstatus.widthAnchor.constraint(equalToConstant: 16.0),
            msgstatus.heightAnchor.constraint(equalToConstant: 16.0),
            
            loveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 1.5),
            loveButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            loveButton.widthAnchor.constraint(equalToConstant: 40.0),
            loveButton.heightAnchor.constraint(equalToConstant: 40.0),

            reactionStackView.heightAnchor.constraint(equalToConstant: 16.0),
            reactionStackView.leadingAnchor.constraint(equalTo: messageStackView.leadingAnchor),
            
            loveReaction.leadingAnchor.constraint(equalTo: reactionStackView.leadingAnchor),
            loveReaction.heightAnchor.constraint(equalToConstant: 16.0),
            loveReaction.widthAnchor.constraint(equalToConstant: 16.0),
            
            badgeReaction.heightAnchor.constraint(equalToConstant: 16.0),
            badgeReaction.widthAnchor.constraint(equalToConstant: 16.0),

        ])
        
        bubbleLeadingAnchor = bubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.75)
        bubbleLeadingAnchor?.isActive = false
        
        bubbleTrailingAnchor = bubble.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.75)
        bubbleTrailingAnchor?.isActive = true
        
        messageLabelHeightAnchor = msgtxt.heightAnchor.constraint(equalToConstant: 0.0)
        messageLabelHeightAnchor?.isActive = true
        
    
        // tapRecognizers
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        messageStackView.addGestureRecognizer(longPressRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        messageStackView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    func config(message: Message, isIncoming: Bool, isLast: Bool, with imgURL: String) {
        
        self.message = message
        self.isIncoming = isIncoming
        
        // Text message
        if let text = message.getValue(forField: .text) as? String {
            msgtxt.text = text
            msgtxt.textColor = isIncoming ? .secondary : .background
            messageLabelHeightAnchor?.constant = msgtxt.requiredHeight
        }
        
        // Bubbles!
        bubble.backgroundColor = isIncoming ? UIColor.tertiary.withAlphaComponent(0.5) : .primary
        bubble.layer.borderColor = isIncoming ? UIColor.tertiary.withAlphaComponent(0.5).cgColor : UIColor.primary.cgColor
        bubbleTrailingAnchor?.isActive = isIncoming ? false : true
        bubbleLeadingAnchor?.isActive = isIncoming ? true : false
        
        // Message status (sent, delivered or read)
        msgstatus.isHidden = isIncoming ? true : false
        
        let isRead = message.getValue(forField: .isRead) as! Bool
        let isDelivered = message.getValue(forField: .isDelivered) as! Bool
        let isSent = message.getValue(forField: .isSent) as! Bool
        
        if !isSent {
            msgstatus.image = UIImage(named: "message-notsent")!.withRenderingMode(.alwaysOriginal)
            
        } else if isSent && !isDelivered {
            msgstatus.image = UIImage(named: "message-sent")!.withRenderingMode(.alwaysOriginal) // change this image!
            
        } else if isDelivered && !isRead {
            msgstatus.image = UIImage(named: "message-delivered")!.withRenderingMode(.alwaysOriginal)
            
        } else {
            
            if imgURL != "" {
                msgstatus.setImage(with: imgURL)
            } else {
                msgstatus.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            }
            
            // If messages are read, only show msgstatus in the last message
            msgstatus.isHidden = isLast ? false : true
        }
        
        // Recipient's love button
        loveButton.isHidden = isIncoming ? false : true
        
        // Reaction view
        reactionStackView.isHidden = true // empty state
        
        // Sender badge image
        if imgURL != "" {
            badgeReaction.setImage(with: imgURL)
        } else {
            badgeReaction.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
        }
        
        // Reaction logic
        let receiver = message.getValue(forField: .receiver) as! String
        if let reactions = message.getValue(forField: .hasReaction) as? [String : String],
            let reaction = reactions[receiver] {
            
            isLoved = true
            if isIncoming {
                
                // Love button displays a filled heart
                if reaction == "heart" {
                    loveButton.setImage(UIImage(named: "heart-filled")!.withRenderingMode(.alwaysTemplate), for: .normal)
                    loveButton.imageView?.tintColor = .primary
                }
                
            } else {
                
                // Reaction view is shown to the sender
                reactionStackView.isHidden = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        msgtxt.text = ""
        
        loveButton.setImage(UIImage(named: "heart-unfilled")!.withRenderingMode(.alwaysTemplate), for: .normal)
        loveButton.imageView?.tintColor = .tertiary
        
        // Reaction stack view (loveReaction + badgeReaction)
        reactionStackView.isHidden = true
    }
    
    @objc func spreadLove() {
        
        if !isLoved {
            loveButton.setImage(UIImage(named: "heart-filled")!.withRenderingMode(.alwaysTemplate), for: .normal)
            loveButton.imageView?.tintColor = .primary
            loveButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 8.0, options: [], animations: {
                self.loveButton.transform = .identity
            }, completion: nil)
            
        } else {
            loveButton.setImage(UIImage(named: "heart-unfilled")!.withRenderingMode(.alwaysTemplate), for: .normal)
            loveButton.imageView?.tintColor = .tertiary
        }
        isLoved = !isLoved
        
        // Acknowledges gesture to ChatLogViewController
        self.gestureRecognizerDelegate?.doubleTapDetected(in: indexPath, with: message, and: isLoved)
    }
    
    // MARK: - UIGestureRecognizer
    
    @objc func doubleTap(sender: UITapGestureRecognizer) {
        
        guard sender.state == .ended else { return }
        
        if isIncoming {
            spreadLove()
        }
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        guard sender.state == .began else { return }
        self.gestureRecognizerDelegate?.longPressDetected(in: indexPath, with: message, from: sender)
    }
}
