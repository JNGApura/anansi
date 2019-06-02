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
    
    let borderView : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.layer.borderColor = UIColor.tertiary.cgColor
        v.layer.borderWidth = 1.5
        v.layer.cornerRadius = 22.0
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var sendButton : UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "Compass-Full")!.withRenderingMode(.alwaysOriginal), for: .normal)
        b.imageView?.contentMode = .center
        b.imageView?.transform = CGAffineTransform(scaleX: 0.22, y: 0.22)
        b.setTitleColor(.primary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.layer.cornerRadius = 22.0
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    var sendButtonTrailingAnchor: NSLayoutConstraint?
    
    lazy var inputTextView : UITextView = {
        let tf = UITextView()
        tf.layer.borderColor = UIColor.clear.cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 22.0
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.placeholder = ""
        tf.contentInset = UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 4.0)
        tf.isScrollEnabled = false
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
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
        [visualEffectView, sendButton, borderView, inputTextView].forEach { addSubview($0)}
        
        // Add layout constraints
        NSLayoutConstraint.activate([
            
            sendButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -Const.marginEight),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight),
            sendButton.widthAnchor.constraint(equalToConstant: 44.0),
            sendButton.heightAnchor.constraint(equalToConstant: 44.0),

            borderView.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight),
            borderView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -Const.marginEight),
            borderView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -Const.marginEight),
            
            inputTextView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 2.0),
            inputTextView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: Const.marginEight),
            inputTextView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -2.0),
            inputTextView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -Const.marginEight),
            
        ])        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSend() {
        
        let message = (inputTextView.text)!
        
        if message.count == 0 {
            delegate?.sendMessage(message: ":compass:")
        } else {
            delegate?.sendMessage(message: message)
        }
        
        // return button to initial scale
        UIView.animate(withDuration: 0.2) {
            self.sendButton.imageView!.transform = CGAffineTransform(scaleX: 0.22, y: 0.22)
        }
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
            UIView.animate(withDuration: 0.2) {
                self.sendButton.imageView!.transform = CGAffineTransform(rotationAngle:  CGFloat.pi / 2).concatenating(CGAffineTransform(scaleX: 0.4, y: 0.4))
            }
            
        } else {
            
            textView.placeholder = placeholderText
            UIView.animate(withDuration: 0.2) {
                self.sendButton.imageView!.transform = CGAffineTransform(scaleX: 0.22, y: 0.22)
            }
        }
        
        return true
    }
}


