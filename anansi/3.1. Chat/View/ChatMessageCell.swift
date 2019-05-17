//
//  ChatMessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    // MARK: Custom initializers
    var message: Message!
    
    let messageLabel : UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.textAlignment = .left
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let bubbleView: UIView = {
        let bv = UIView()
        bv.layer.borderWidth = 2
        bv.layer.borderColor = UIColor.red.cgColor
        bv.layer.cornerRadius = 20
        bv.layer.masksToBounds = true
        bv.clipsToBounds = true
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()

    let timestampView : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.textAlignment = .right
        l.backgroundColor = .background
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        //l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let statusView : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.textAlignment = .right
        l.backgroundColor = .background
        l.font = UIFont.boldSystemFont(ofSize: Const.captionFontSize)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let horizontalStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.isHidden = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let verticalStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // To be able to modify the constraints externally
    var bubbleViewTrailingAnchor: NSLayoutConstraint?
    var bubbleViewLeadingAnchor: NSLayoutConstraint?
    var messageLabelHeightAnchor: NSLayoutConstraint?
    var bubbleViewHeightAnchor: NSLayoutConstraint?
    var statusViewWidthAnchor: NSLayoutConstraint?
    
    // MARK: Cell init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // Add subviews
        [timestampView, statusView].forEach( {horizontalStackView.addArrangedSubview($0)} )
        [bubbleView, horizontalStackView].forEach( {verticalStackView.addArrangedSubview($0)} )
        [verticalStackView, messageLabel].forEach( {addSubview($0)} )
        
        // Add layout constraints to subviews
        NSLayoutConstraint.activate([
            
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 3.0),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),

            horizontalStackView.topAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            horizontalStackView.heightAnchor.constraint(equalToConstant: Const.timeDateHeightChatCells),
            horizontalStackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginEight * 4.0),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Const.marginEight),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Const.marginEight),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Const.marginEight * 2.0),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Const.marginEight * 2.0),
            
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 250.0),
            bubbleView.topAnchor.constraint(equalTo: verticalStackView.topAnchor),
            bubbleView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant: Const.marginEight * 2.0)
        ])
        
        bubbleViewLeadingAnchor = bubbleView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor)
        bubbleViewLeadingAnchor?.isActive = false
        
        bubbleViewTrailingAnchor = bubbleView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor)
        bubbleViewTrailingAnchor?.isActive = true
        
        messageLabelHeightAnchor = messageLabel.heightAnchor.constraint(equalToConstant: 24.0)
        messageLabelHeightAnchor?.isActive = true
        
        statusViewWidthAnchor = statusView.widthAnchor.constraint(lessThanOrEqualToConstant: 72.0)
        statusViewWidthAnchor?.isActive = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    func config(message: Message, isIncoming: Bool, isLast: Bool) {
        
        self.message = message
        
        if let text = message.getValue(forField: .text) as? String {
            messageLabel.text = text
            messageLabel.textColor = isIncoming ? .secondary : .background

            messageLabelHeightAnchor?.constant = messageLabel.requiredHeight
        }
        
        bubbleView.backgroundColor = isIncoming ? UIColor.tertiary.withAlphaComponent(0.5) : .primary
        bubbleView.layer.borderColor = isIncoming ? UIColor.tertiary.withAlphaComponent(0.5).cgColor : UIColor.primary.cgColor
        verticalStackView.alignment = isIncoming ? .leading : .trailing
        
        // Timestamp label
        let timestampSec = (message.getValue(forField: .timestamp) as? NSNumber)!.doubleValue
        let timestr = timestring(from: NSDate(timeIntervalSince1970: timestampSec))
        timestampView.text = "\(timestr)"
        timestampView.textAlignment = isIncoming ? .left : .right
        timestampView.isHidden = isLast ? true : false
        
        horizontalStackView.isHidden = isLast ? false : true
        statusView.isHidden = isLast ? false : true
        
        // Bubbles
        if isIncoming {

            bubbleViewTrailingAnchor?.isActive = false
            bubbleViewLeadingAnchor?.isActive = true
            
        } else {
            
            bubbleViewTrailingAnchor?.isActive = true
            bubbleViewLeadingAnchor?.isActive = false
            
            // If the last message is mine, then status is visible
            if isLast  {
                
                let isRead = message.getValue(forField: .isRead) as? Bool
                let isDelivered = message.getValue(forField: .isDelivered) as? Bool
                statusView.text = isRead! ? " Read" : isDelivered! ? " Delivered" : " Sent"
                timestampView.text = "\(timestr) ·"
            }
        }
    }
    
    func handleTimeShowRequest() {
        
        // Shows or hides horizontalStackView with timestamp
        horizontalStackView.isHidden = statusView.isHidden && !horizontalStackView.isHidden
        
        // Behavior is a bit different for the last cell (if isLast = true)
        if !statusView.isHidden {
            statusViewWidthAnchor?.constant = statusView.requiredWidth
            timestampView.isHidden = !timestampView.isHidden
        }
    }
}
