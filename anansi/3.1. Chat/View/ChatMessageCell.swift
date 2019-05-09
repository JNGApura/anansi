//
//  ChatMessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    // MARK: Custom initializers
    
    var message: Message? {
        didSet {
            textView.text = message?.text
            bubbleViewWidthAnchor?.constant = estimateFrameForText(text: (message?.text)!).width + 28.0 // 28: safe margin?
        }
    }
        
    let timeDate : UILabel = {
        let l = UILabel()
        l.text = "time"
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.backgroundColor = .background
        l.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    var timeDateHeightAnchor: NSLayoutConstraint? // To be able to modify the constraint externally
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.text = "message"
        tv.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textAlignment = .left
        return tv
    }()
    
    let bubbleView: UIView = {
        let bv = UIView()
        bv.layer.borderWidth = 2
        bv.layer.borderColor = UIColor.red.cgColor
        bv.layer.cornerRadius = 16
        bv.layer.masksToBounds = true
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    let statusView : UILabel = {
        let l = UILabel()
        l.text = "status"
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.textAlignment = .right
        l.backgroundColor = .background
        l.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // To be able to modify the constraints externally
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewHeightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    // MARK: Cell init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add subviews
        [timeDate, bubbleView, statusView].forEach( {stackView.addArrangedSubview($0)} )
        [stackView, textView].forEach( {addSubview($0)} )
        
        // Add layout constraints to subviews
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            
            timeDate.heightAnchor.constraint(equalToConstant: Const.timeDateHeightChatCells),
            timeDate.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginEight * 4.0),
            
            statusView.heightAnchor.constraint(equalToConstant: Const.timeDateHeightChatCells),
            statusView.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginEight * 4.0),

            textView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Const.marginEight),
            textView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            textView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Const.marginEight),
            textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor),
        ])
        
        bubbleViewLeftAnchor = bubbleView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        bubbleViewLeftAnchor?.isActive = false
        
        bubbleViewRightAnchor = bubbleView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 240)
        bubbleViewWidthAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 224, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Const.bodyFontSize)], context: nil)
    }
}
