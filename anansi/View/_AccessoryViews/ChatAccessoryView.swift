//
//  ChatAccessoryView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatAccessoryView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    var chatLogController: ChatLogController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            chatLogController?.collectionView?.addGestureRecognizer(tap)
        }
    }
    
    private let sendButton : UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "send").withRenderingMode(.alwaysTemplate), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    var sendButtonTrailingAnchor: NSLayoutConstraint?
    
    private let uploadImageView : UIImageView = {
        let i = UIImageView()
        i.isUserInteractionEnabled = true
        i.image = #imageLiteral(resourceName: "multimedia").withRenderingMode(.alwaysTemplate)
        i.tintColor = .primary
        i.translatesAutoresizingMaskIntoConstraints = false
        i.isHidden = false
        return i
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
        tf.layer.cornerRadius = 8
        tf.clipsToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
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
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // UI
        isOpaque = false
        tintColor = .primary
        autoresizingMask = .flexibleHeight
        
        // Blur effect
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = self.frame
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        
        // Add subviews
        [visualEffectView, uploadImageView, inputTextView, sendButton, isTypingBox].forEach { addSubview($0)}
        
        // Add layout constraints
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            
            sendButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -6.0),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0),
            sendButton.widthAnchor.constraint(equalToConstant: 44.0),
            sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor),
            
            uploadImageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -12.0),
            uploadImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11.0),
            uploadImageView.widthAnchor.constraint(equalToConstant: 30.0),
            uploadImageView.heightAnchor.constraint(equalTo: uploadImageView.widthAnchor),
            
            inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            inputTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            inputTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -8.0),
            inputTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -52.0),
            
            isTypingBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            isTypingBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            isTypingBox.bottomAnchor.constraint(equalTo: inputTextView.topAnchor, constant: -2.0),
            isTypingBox.heightAnchor.constraint(equalToConstant: 17.0)
        ])
    }
    
}

// UITextViewDelegate functions
extension ChatAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        chatLogController?.isTyping = textView.text != ""
        
        // If textView.text is empty, then hides sendButton
        if textView.text.isEmpty {
            uploadImageView.isHidden = false
            sendButton.isHidden = true
            textView.placeholder = "Type a message"
            
        } else {
            uploadImageView.isHidden = true
            sendButton.isHidden = false
            textView.placeholder = ""
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // If textView.text finishes editing, then hides sendButton
        if textView.text.isEmpty {
            uploadImageView.isHidden = false
            sendButton.isHidden = true
        }
        textView.resignFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        chatLogController?.isTyping = false
        return true
    }
    
    @objc func dismissKeyboard() {
        inputTextView.resignFirstResponder()
    }
}
