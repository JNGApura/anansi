//
//  Header.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 23/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import Kingfisher

// Header, UIView subclass
class Header : UIView {
    
    let headerTitle: UILabel = {
        let t = UILabel()
        t.textColor = .secondary
        t.font = UIFont.boldSystemFont(ofSize: Const.largeTitleFontSize)
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let bottomLine: UIView = {
        let l = UIView()
        l.isOpaque = true
        l.backgroundColor = .primary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let profileButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .background
        b.layer.cornerRadius = 16.0
        b.layer.masksToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let alertButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "alert")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .primary
        b.backgroundColor = .background
        b.layer.cornerRadius = 12.0
        b.layer.masksToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    let actionButton: UIButton = {
        let b = UIButton()
        b.tintColor = .secondary
        b.backgroundColor = .background
        b.layer.cornerRadius = 16.0
        b.layer.masksToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add headerTitle and headerBottomBorder subviews
        [headerTitle, bottomLine, alertButton, profileButton, actionButton].forEach { addSubview($0) }
        
        // Adds layout constraints
        NSLayoutConstraint.activate([

            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Const.marginEight * 2.0),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea + 1.0),
            bottomLine.widthAnchor.constraint(equalToConstant: Const.marginSafeArea * 2.0),
            bottomLine.heightAnchor.constraint(equalToConstant: 2.0),
            
            headerTitle.bottomAnchor.constraint(equalTo: bottomLine.topAnchor, constant: -4.0),
            headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            
            alertButton.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            alertButton.leadingAnchor.constraint(equalTo: headerTitle.trailingAnchor, constant: Const.marginEight),
            alertButton.widthAnchor.constraint(equalToConstant: 24.0),
            alertButton.heightAnchor.constraint(equalToConstant: 24.0),
            
            profileButton.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            profileButton.widthAnchor.constraint(equalToConstant: 32.0),
            profileButton.heightAnchor.constraint(equalToConstant: 32.0),
            
            actionButton.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -Const.marginEight * 2.0),
            actionButton.widthAnchor.constraint(equalToConstant: 32.0),
            actionButton.heightAnchor.constraint(equalToConstant: 32.0)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setProfileImage()
    }
    
    // Sets title name
    func setTitleName(name: String) {
        self.headerTitle.text = name
    }
    
    // Sets titleColor, default: Color.secondary
    func setTitleColor(textColor: UIColor) {
        self.headerTitle.textColor = textColor
    }
    
    // Sets bottomBorderColor, default: Color.primary
    func setBottomBorderColor(lineColor: UIColor) {
        self.bottomLine.backgroundColor = lineColor
    }
    
    // Sets background color, default: Color.background
    func setBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }
    
    // Sets profile image, if available
    func setProfileImage() {
        
        if let myProfileImage = userDefaults.string(for: userInfoType.profileImageURL.rawValue) {

            profileButton.kf.setImage(with: URL(string: myProfileImage), for: .normal, placeholder: UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal))
            profileButton.kf.setBackgroundImage(with: URL(string: myProfileImage), for: .normal, placeholder: UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal))
        } else {
            
            profileButton.setImage(UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal), for: .normal)
            profileButton.setBackgroundImage(UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    // Handles alert button
    func showAlertButton() {
        alertButton.isHidden = false
    }
    
    func hideAlertButton() {
        alertButton.isHidden = true
    }
}

// HeaderWithProfileImage is a subclass of UIView
class ProfileHeader : UIView {
    
    var profileImage: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
        i.layer.cornerRadius = Const.profileImageHeight / 2
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.layer.borderWidth = 4
        i.layer.borderColor = UIColor.background.cgColor
        i.layer.masksToBounds = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    private let headerTitle: UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .secondary
        l.textAlignment = .left
        l.font = UIFont.boldSystemFont(ofSize: Const.largeTitleFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let headerBottomBorder: UIView = {
        let v = UIView()
        v.isOpaque = true
        v.backgroundColor = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let occupation: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.textColor = .secondary
        l.textAlignment = .left
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let location: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.textColor = .secondary
        l.textAlignment = .left
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Adds user-related info
        [profileImage, headerTitle, headerBottomBorder, occupation, location].forEach( {addSubview($0)} )
        
        // Adds layout constraints
        NSLayoutConstraint.activate([
            
            profileImage.topAnchor.constraint(equalTo: topAnchor),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            profileImage.widthAnchor.constraint(equalToConstant: Const.profileImageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: Const.profileImageHeight),
            
            headerTitle.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: Const.marginEight * 2.0),
            headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            headerTitle.widthAnchor.constraint(equalTo: widthAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 36.0),
            
            headerBottomBorder.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: Const.marginEight / 2.0),
            headerBottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            headerBottomBorder.widthAnchor.constraint(equalToConstant: Const.marginSafeArea * 2.0),
            headerBottomBorder.heightAnchor.constraint(equalToConstant: 2.0),
            
            occupation.topAnchor.constraint(equalTo: headerBottomBorder.bottomAnchor, constant: Const.marginSafeArea / 2.0),
            occupation.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            occupation.widthAnchor.constraint(equalTo: widthAnchor),
            occupation.heightAnchor.constraint(equalToConstant: 20.0),
            
            location.topAnchor.constraint(equalTo: occupation.bottomAnchor, constant: Const.marginEight / 2.0),
            location.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            location.widthAnchor.constraint(equalTo: widthAnchor),
            location.heightAnchor.constraint(equalToConstant: 20.0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets title name
    func setTitleName(name: String) {
        self.headerTitle.text = name
    }
    
    // Sets titleColor, default: Color.secondary
    func setTitleColor(textColor: UIColor) {
        self.headerTitle.textColor = textColor
    }
    
    // Sets bottomBorderColor, default: Color.primary
    func setBottomBorderColor(lineColor: UIColor) {
        self.headerBottomBorder.backgroundColor = lineColor
    }
    
    // Sets occupation, default: N/A
    func setOccupation(_ text: String) {
        self.occupation.text = text
    }
    
    // Sets location, default: N/A
    func setLocation(_ text: String) {
        self.location.text = text
    }
    
    // Sets profile image, default: profileImageTemplate
    func setProfileImage(image: UIImage) {
        self.profileImage.image = image.withRenderingMode(.alwaysOriginal)
    }
}
