//
//  TextViewTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

protocol TextViewTableCellDelegate: class {
    func didChangeValueIn(field: userInfoType, to value: String)
    func didBeginEditingTextView(field: userInfoType)
}

class TextViewTableCell: UITableViewCell {
    
    var questionLabel: UILabel = {
        let l = UILabel()
        l.text = "Is this a question?"
        l.textColor = UIColor.secondary.withAlphaComponent(0.75)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var dataTextView: UITextView = {
        let tv = UITextView()
        tv.delegate = self
        tv.textColor = .secondary
        tv.backgroundColor = .background
        tv.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = .secondary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // data
    var field: userInfoType!
    var previousText: String!
    var placeholderText: String!
    
    weak var delegate: TextViewTableCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        // Add everything as subviews to sectionView
        [questionLabel, dataTextView, bottomLine].forEach { addSubview($0) }
        
        // Add NSLayoutConstraints
        NSLayoutConstraint.activate([
            
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            questionLabel.heightAnchor.constraint(equalToConstant: 14.0),
            questionLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0),
            
            dataTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea - 6.0),
            dataTextView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 4.0),
            dataTextView.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0 + 12.0),
            
            bottomLine.topAnchor.constraint(equalTo: dataTextView.bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
            bottomLine.heightAnchor.constraint(equalToConstant: 1.0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configureWithField(field: userInfoType, andValue value: String?, withLabel label: String, withPlaceholder placeholder: String) {
                
        self.field = field
        
        questionLabel.text = label
        dataTextView.text = value ?? ""

        placeholderText = placeholder
        previousText = value ?? ""
    }
    
    func valueChanged(_ sender: UITextView) {
        self.delegate?.didChangeValueIn(field: field, to: sender.text!)
    }
    
    // MARK: - Layout
    
    func estimateSizeFor(_ textView: UITextView) {
    
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                
                valueChanged(textView)
            }
        }
    }
}

extension TextViewTableCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        estimateSizeFor(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }

        //textView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        self.delegate?.didBeginEditingTextView(field: field)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .secondary
        }
        
        //textView.becomeFirstResponder()
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textLength = prospectiveText.count
        let limit = 240
        
        if textLength > limit {
            prospectiveText.removeLast(textLength - limit)
            
            textView.text = prospectiveText
            estimateSizeFor(textView)
            
            return false
        }

        return true
    }
    
}
