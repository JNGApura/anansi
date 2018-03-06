//
//  QuestionCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 11/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell { //}, UITextViewDelegate {
    
    // Create question label
    var mappedProperty: String?
    
    lazy var questionLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.alpha = 0.0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // Create character limit label
    lazy var characterLimit: UILabel = {
        let l = UILabel()
        l.textColor = .primary
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // Create textfield
    lazy var textView: UITextView = {
        let tf = UITextView()
        tf.textContainer.maximumNumberOfLines = 1
        tf.backgroundColor = .clear
        tf.textColor = .secondary
        tf.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        tf.textContainerInset = UIEdgeInsets(top: 2, left: -6, bottom: -2, right: 0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isScrollEnabled = false
        return tf
    }()
    var textViewHeightAnchor: NSLayoutConstraint?
    
    // Create border line below the textfield
    let borderLine: UIView = {
        let v = UIView()
        v.backgroundColor = .secondary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Create error label
    let errorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .primary
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        // Add everything as subviews to sectionView
        [questionLabel, characterLimit, textView, borderLine, errorLabel].forEach { addSubview($0) }
        
        // Add NSLayoutConstraints
        NSLayoutConstraint.activate([
            
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight - 2.0),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            questionLabel.trailingAnchor.constraint(equalTo: characterLimit.leadingAnchor),
            questionLabel.heightAnchor.constraint(equalToConstant: 26.0),
            
            characterLimit.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight - 2.0),
            characterLimit.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            characterLimit.heightAnchor.constraint(equalToConstant: 26.0),
            
            textView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            
            borderLine.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0.0),
            borderLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            borderLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            borderLine.heightAnchor.constraint(equalToConstant: 1.0),
            
            errorLabel.topAnchor.constraint(equalTo: borderLine.bottomAnchor, constant: 4.0),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            errorLabel.heightAnchor.constraint(equalToConstant: 15.0),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.0),
        ])
        
        textViewHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 26.0)
        textViewHeightAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: frame.width - 36.0, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Const.calloutFontSize)], context: nil)
    }
    
}
