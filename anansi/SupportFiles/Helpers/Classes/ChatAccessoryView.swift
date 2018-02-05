//
//  ChatAccessoryView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatAccessoryView: CustomViewCorrection {
    
    var chatLogController: ChatLogController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
        }
    }
    
    private let sendButton : UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.setImage(#imageLiteral(resourceName: "send").withRenderingMode(.alwaysTemplate), for: .normal)
        return b
    }()
    var sendButtonTrailingAnchor: NSLayoutConstraint?
    
    private let uploadImageView : UIImageView = {
        let i = UIImageView()
        i.isUserInteractionEnabled = true
        i.image = #imageLiteral(resourceName: "multimedia").withRenderingMode(.alwaysTemplate)
        i.tintColor = .primary
        return i
    }()
    
    private let separatorLineView : UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        return v
    }()
    
    lazy var inputTextView : UITextView = {
        let tf = UITextView()
        tf.placeholder = "Type a message"
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.delegate = self
        tf.isScrollEnabled = false
        tf.layer.borderColor = UIColor.tertiary.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 4
        tf.clipsToBounds = true
        return tf
    }()
    var inputTextViewHeightAnchor: NSLayoutConstraint?
    
    let isTypingBox : UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .secondary
        l.backgroundColor = .background
        l.font = UIFont.boldSystemFont(ofSize: Const.captionFontSize)
        l.isHidden = true
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // UI
        backgroundColor = .background
        tintColor = .primary
        autoresizingMask = .flexibleHeight
        
        // Add subviews
        [uploadImageView, inputTextView, sendButton, separatorLineView, isTypingBox].forEach { addSubview($0)}
        
        // Add layout constraints
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
        
            uploadImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12.0),
            uploadImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
            uploadImageView.widthAnchor.constraint(equalToConstant: 30.0),
            uploadImageView.heightAnchor.constraint(equalTo: uploadImageView.widthAnchor),
            
            sendButton.topAnchor.constraint(equalTo: topAnchor, constant: 6.0),
            sendButton.widthAnchor.constraint(equalToConstant: 44.0),
            sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor),
            
            inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            inputTextView.leadingAnchor.constraint(equalTo: uploadImageView.trailingAnchor, constant: 12.0),
            inputTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -8.0),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8.0),
            
            separatorLineView.topAnchor.constraint(equalTo: topAnchor),
            separatorLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            isTypingBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            isTypingBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            isTypingBox.bottomAnchor.constraint(equalTo: inputTextView.topAnchor, constant: -Const.marginEight),
            isTypingBox.heightAnchor.constraint(equalToConstant: 22.0)
        ])
        
        sendButtonTrailingAnchor = sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 44.0) // hidden
        sendButtonTrailingAnchor?.isActive = true
    }
    
}

class CustomViewCorrection: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
// UITextViewDelegate functions
extension ChatAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        chatLogController?.isTyping = textView.text != ""
        
        // If textView.text is empty, then hides sendButton
        if textView.text.isEmpty {
            sendButtonTrailingAnchor?.constant = 44.0
            textView.placeholder = "Type a message"
            
        } else {
            sendButtonTrailingAnchor?.constant = -8.0
            textView.placeholder = ""
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // If textView.text finishes editing, then hides sendButton
        if textView.text.isEmpty {
            sendButtonTrailingAnchor?.constant = 44.0
        }
        textView.resignFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        chatLogController?.isTyping = false
        return true
    }
}
