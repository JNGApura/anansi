//
//  ChatAccessoryView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol ChatAccessoryDelegate {
    func sendMessage(message: String)
    func isTypingMessage(value: Bool)
}

class ChatAccessoryView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    var delegate: ChatAccessoryDelegate?
    
    var placeholderText = String() {
        didSet {
            inputTextView.placeholder = placeholderText
        }
    }
    
    lazy var sendButton : UIButton = {
        let b = UIButton()
        b.setTitle("Send", for: .normal)
        b.setTitleColor(.primary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isEnabled = false
        b.alpha = 0.4
        b.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return b
    }()
    var sendButtonTrailingAnchor: NSLayoutConstraint?
    
    lazy var inputTextView : UITextView = {
        let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.placeholder = ""
        tf.isScrollEnabled = false
        tf.layer.borderColor = UIColor.tertiary.cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 22.0
        tf.clipsToBounds = true
        tf.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
        tf.textContainerInset = UIEdgeInsets(top: 9.0, left: 0.0, bottom: 8.0, right: 76.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    //var inputTextViewHeightAnchor: NSLayoutConstraint?
    
    let isTypingBox : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let isTypingLabel : UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.captionFontSize)
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
        [visualEffectView, inputTextView, sendButton, isTypingBox].forEach { addSubview($0)}
        isTypingBox.addSubview(isTypingLabel)
        
        // Add layout constraints
        NSLayoutConstraint.activate([
            
            sendButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -5.0),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea - 2.0),
            sendButton.widthAnchor.constraint(equalToConstant: 44.0),
            sendButton.heightAnchor.constraint(equalToConstant: 44.0),
            
            inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            inputTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea / 2.0),
            inputTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -Const.marginEight),
            inputTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight),
            
            isTypingBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            isTypingBox.trailingAnchor.constraint(equalTo: trailingAnchor),
            isTypingBox.bottomAnchor.constraint(equalTo: inputTextView.topAnchor, constant: -2.0),
            isTypingBox.heightAnchor.constraint(equalToConstant: 17.0),
            
            isTypingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea + 9.0),
            isTypingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            isTypingLabel.centerYAnchor.constraint(equalTo: isTypingBox.centerYAnchor, constant: -2.0),
        ])
        
        inputTextView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSend() {
        let message = (inputTextView.text)!
        delegate?.sendMessage(message: message)
    }
}

// MARK: - UITextViewDelegate

extension ChatAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.isTypingMessage(value: textView.text != "")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        delegate?.isTypingMessage(value: false)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textLength = prospectiveText.count
        
        // Enables button when length > 0
        if textLength > 0 {
            
            textView.placeholder = ""
            sendButton.isEnabled = true
            sendButton.alpha = 1.0
            
        } else {
            textView.placeholder = placeholderText
            sendButton.isEnabled = false
            sendButton.alpha = 0.4
        }
        
        return true
    }
}

