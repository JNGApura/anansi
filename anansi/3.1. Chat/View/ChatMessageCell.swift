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
        i.isHidden = true
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
    
    let loveReaction : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "heart-filled")!.withRenderingMode(.alwaysTemplate)
        i.tintColor = .primary
        i.contentMode = .scaleAspectFit
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let horizontalStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.isHidden = true
        sv.contentMode = .top
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let messageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // To be able to modify the constraints externally
    var bubbleTrailingAnchor: NSLayoutConstraint?
    var bubbleLeadingAnchor: NSLayoutConstraint?
    var messageLabelHeightAnchor: NSLayoutConstraint?
    var bubbleViewHeightAnchor: NSLayoutConstraint?
    
    // MARK: Cell init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // tapRecognizer, placed in viewDidLoad
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        bubble.addGestureRecognizer(longPressRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        bubble.addGestureRecognizer(tap)
        
        selectionStyle = .none
        
        // Add subviews
        [bubble, msgtxt, loveButton, msgstatus, loveReaction].forEach { addSubview($0) }
        
        // Add layout constraints to subviews
        NSLayoutConstraint.activate([
            
            bubble.topAnchor.constraint(equalTo: topAnchor, constant: 3.0),
            bubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0),
            bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 262.0),
            
            msgtxt.topAnchor.constraint(equalTo: bubble.topAnchor, constant: Const.marginEight),
            msgtxt.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -Const.marginEight),
            msgtxt.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: Const.marginEight * 2.0),
            msgtxt.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -Const.marginEight * 2.0),
            
            loveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight / 2.0),
            loveButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            loveButton.widthAnchor.constraint(equalToConstant: 40.0),
            loveButton.heightAnchor.constraint(equalToConstant: 40.0),
            
            msgstatus.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 2.0),
            msgstatus.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight),
            msgstatus.heightAnchor.constraint(equalToConstant: 16.0),
            msgstatus.widthAnchor.constraint(equalToConstant: 16.0),
            
            loveReaction.topAnchor.constraint(equalTo: msgstatus.topAnchor),
            loveReaction.trailingAnchor.constraint(equalTo: msgstatus.leadingAnchor, constant: -Const.marginEight / 2.0),
            loveReaction.heightAnchor.constraint(equalToConstant: 16.0),
            loveReaction.widthAnchor.constraint(equalToConstant: 16.0),
        ])
        
        bubbleLeadingAnchor = bubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0)
        bubbleLeadingAnchor?.isActive = false
        
        bubbleTrailingAnchor = bubble.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0)
        bubbleTrailingAnchor?.isActive = true
        
        messageLabelHeightAnchor = msgtxt.heightAnchor.constraint(equalToConstant: 0.0)
        messageLabelHeightAnchor?.isActive = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    func config(message: Message, isIncoming: Bool, isLast: Bool, with imgURL: String) {
        
        self.message = message
        self.isIncoming = isIncoming
        
        if let text = message.getValue(forField: .text) as? String {
            msgtxt.text = text
            msgtxt.textColor = isIncoming ? .secondary : .background
            messageLabelHeightAnchor?.constant = msgtxt.requiredHeight
        }
        
        bubble.backgroundColor = isIncoming ? UIColor.tertiary.withAlphaComponent(0.5) : .primary
        bubble.layer.borderColor = isIncoming ? UIColor.tertiary.withAlphaComponent(0.5).cgColor : UIColor.primary.cgColor
        
        msgstatus.isHidden = isLast ? false : true
        
        // Bubbles
        if isIncoming {
            bubbleTrailingAnchor?.isActive = false
            bubbleLeadingAnchor?.isActive = true
            
        } else {
            bubbleTrailingAnchor?.isActive = true
            bubbleLeadingAnchor?.isActive = false
            
            // If the last message is mine, then status is visible
            if isLast  {
                
                let isRead = message.getValue(forField: .isRead) as? Bool
                let isDelivered = message.getValue(forField: .isDelivered) as? Bool
                let isSent = message.getValue(forField: .isSent) as? Bool
                
                if isRead! {
                    if imgURL != "" { msgstatus.setImage(with: imgURL) }
                    else { msgstatus.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal) }
                }
                else if isSent! || isDelivered! { msgstatus.image = UIImage(named: "message-delivered")!.withRenderingMode(.alwaysOriginal) }
                else { msgstatus.image = UIImage(named: "message-sent")!.withRenderingMode(.alwaysOriginal) }
            }
        }
        
        // Reactions
        loveButton.isHidden = isIncoming ? false : true
        loveReaction.isHidden = true
        
        // receiver reacts to the sender
        let receiver = message.getValue(forField: .receiver) as? String
        
        if let reactions = message.getValue(forField: .hasReaction) as? [String : String],
            let reaction = reactions[receiver!] {
            
            isLoved = true
            if isIncoming {
                
                if reaction == "heart" {
                    loveButton.setImage(UIImage(named: "heart-filled")!.withRenderingMode(.alwaysTemplate), for: .normal)
                    loveButton.imageView?.tintColor = .primary
                }
                
            } else {
                
                // Something wrong here, check later
                loveReaction.isHidden = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        msgtxt.text = ""
        
        loveButton.setImage(UIImage(named: "heart-unfilled")!.withRenderingMode(.alwaysTemplate), for: .normal)
        loveButton.imageView?.tintColor = .tertiary
        
        loveReaction.isHidden = true
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
