//
//  TextFieldTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 21/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

protocol TextFieldTableCellDelegate: class {
    func fieldDidBeginEditing(field: userInfoType)
    func field(field: userInfoType, changedValueTo value: String)
    func fieldChangeForbidden(field: userInfoType)
}

class TextFieldTableCell: UITableViewCell {
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_@.-/"
    
    var questionLabel: UILabel = {
        let l = UILabel()
        l.text = "Is this a question?"
        l.textColor = UIColor.secondary.withAlphaComponent(0.75)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var dataTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.placeholder = "This is the answer"
        tf.textColor = .secondary
        tf.backgroundColor = .background
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isUserInteractionEnabled = true
        tf.returnKeyType = UIReturnKeyType.done
        return tf
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
    weak var delegate: TextFieldTableCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        // Add everything as subviews to sectionView
        [questionLabel, dataTextField, bottomLine].forEach { addSubview($0) }
        
        // Add NSLayoutConstraints
        NSLayoutConstraint.activate([
            
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            questionLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0),
            
            dataTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            dataTextField.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 4.0),
            dataTextField.heightAnchor.constraint(equalToConstant: 26.0),
            dataTextField.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0),
            
            bottomLine.topAnchor.constraint(equalTo: dataTextField.bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
            bottomLine.heightAnchor.constraint(equalToConstant: 1.0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func valueChanged(_ sender: UITextField) {
        self.delegate?.field(field: field, changedValueTo: sender.text!)
    }
}

extension TextFieldTableCell: UITextFieldDelegate {
    
    func configureWithField(field: userInfoType, andValue value: String?, withLabel label: String, withPlaceholder placeholder: String) {
        
        self.field = field
        questionLabel.text = label
        dataTextField.text = value ?? ""
        dataTextField.placeholder = placeholder
        
        previousText = value ?? ""
        selectionStyle = .none        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        self.delegate?.fieldDidBeginEditing(field: field)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if previousText != dataTextField.text {
            
            if dataTextField.text == "" {
                
                if (field == .name || field == .occupation || field == .location) {
                
                    dataTextField.text = previousText
                    self.delegate?.fieldChangeForbidden(field: field)
                
                } else { dataTextField.text = "" }
            }
            
            valueChanged(textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if [.sharedEmail, .website, .linkedin].contains(field) {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
        
            return (string == filtered)
        } else {

            return true
        }
    }
    
}
