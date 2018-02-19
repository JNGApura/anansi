//
//  Header.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 23/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Header, UIView subclass
class Header : UIView {
    
    let headerTitle: UILabel = {
        let view = UILabel()
        view.textColor = .secondary
        view.font = UIFont.boldSystemFont(ofSize: Const.largeTitleFontSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let headerBottomBorder: UIView = {
        let view = UIView()
        view.isOpaque = true
        view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add headerTitle and headerBottomBorder subviews
        [headerTitle, headerBottomBorder].forEach { addSubview($0) }
        
        // Adds layout constraints
        NSLayoutConstraint.activate([
        
            headerTitle.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 1.5),
            headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),

            headerBottomBorder.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: Const.marginEight - 2.0),
            headerBottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0 + 1.0),
            headerBottomBorder.widthAnchor.constraint(equalToConstant: Const.marginAnchorsToContent * 2.0),
            headerBottomBorder.heightAnchor.constraint(equalToConstant: 2.0)
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
    
    // Sets background color, default: Color.background
    func setBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }
}

// HeaderWithProfileImage is a subclass of Header that allows adding participantTypeBox and profileImage
class HeaderWithProfileImage : Header {
    
    let occupation: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        l.textColor = .background
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let occupationIcon: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "occupation").withRenderingMode(.alwaysTemplate)
        i.contentMode = .scaleAspectFit
        i.tintColor = .background
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let location: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        l.textColor = .background
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let locationIcon: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate)
        i.contentMode = .scaleAspectFit
        i.tintColor = .background
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = Const.profileImageHeight / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Adds user-related info
        [occupationIcon, occupation, locationIcon, location, profileImage].forEach( {addSubview($0)} )
        
        // Adds layout constraints
        NSLayoutConstraint.activate([
            
            occupationIcon.topAnchor.constraint(equalTo: occupation.topAnchor),
            occupationIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            occupationIcon.widthAnchor.constraint(equalToConstant: 16.0),
            occupationIcon.heightAnchor.constraint(equalTo: occupationIcon.widthAnchor),
            
            occupation.topAnchor.constraint(equalTo: topAnchor, constant: 70.0),
            occupation.leadingAnchor.constraint(equalTo: occupationIcon.trailingAnchor, constant: Const.marginEight),
            occupation.trailingAnchor.constraint(equalTo: profileImage.leadingAnchor, constant: -Const.marginEight),
            occupation.heightAnchor.constraint(equalToConstant: 20.0),
            
            locationIcon.topAnchor.constraint(equalTo: location.topAnchor),
            locationIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            locationIcon.widthAnchor.constraint(equalToConstant: 16.0),
            locationIcon.heightAnchor.constraint(equalTo: occupationIcon.widthAnchor),
            
            location.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
            location.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: Const.marginEight),
            location.trailingAnchor.constraint(equalTo: profileImage.leadingAnchor, constant: -Const.marginEight),
            location.heightAnchor.constraint(equalToConstant: 20.0),
            
            profileImage.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 2.0),
            profileImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginEight * 2.0),
            profileImage.widthAnchor.constraint(equalToConstant: Const.profileImageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: Const.profileImageHeight)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets participant type, default: participant
    func setParticipantType(type: String) {
        //self.participantTypeBox.text = type
    }
    
    // Sets occupation, default: N/A
    func setOccupation(_ text: String) {
        self.occupation.text = text
    }
    
    // Sets location, default: N/A
    func setLocation(_ text: String) {
        self.location.text = "From " + text
    }
    
    // Sets profile image, default: profileImageTemplate
    func setProfileImage(image: UIImage) {
        self.profileImage.image = image.withRenderingMode(.alwaysOriginal)
    }

    // Sets tapGestureRecognizer to ProfileImage
    func addTapGestureToProfileImage(tapGesture: UITapGestureRecognizer) {
        self.profileImage.addGestureRecognizer(tapGesture)
    }
}

// HeaderWithProfileImage is a subclass of UIView
class ProfileHeader : UIView {
    
    var profileImage: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
        i.layer.cornerRadius = Const.profileImageHeight / 2
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.layer.borderWidth = 4
        i.layer.borderColor = UIColor.background.cgColor
        i.layer.masksToBounds = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let headerTitle: UILabel = {
        let view = UILabel()
        view.textColor = .secondary
        view.textAlignment = .center
        view.font = UIFont.boldSystemFont(ofSize: Const.largeTitleFontSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let headerBottomBorder: UIView = {
        let view = UIView()
        view.isOpaque = true
        view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let occupation: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.textColor = .secondary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let location: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.textColor = .secondary
        l.textAlignment = .center
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
            profileImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: Const.profileImageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: Const.profileImageHeight),
            
            headerTitle.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: Const.marginEight * 2.0),
            headerTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerTitle.widthAnchor.constraint(equalTo: widthAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 36.0),
            
            headerBottomBorder.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: Const.marginEight / 2.0),
            headerBottomBorder.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerBottomBorder.widthAnchor.constraint(equalToConstant: Const.marginAnchorsToContent * 2.0),
            headerBottomBorder.heightAnchor.constraint(equalToConstant: 2.0),
            
            occupation.topAnchor.constraint(equalTo: headerBottomBorder.bottomAnchor, constant: Const.marginEight * 1.5),
            occupation.centerXAnchor.constraint(equalTo: centerXAnchor),
            occupation.widthAnchor.constraint(equalTo: widthAnchor),
            occupation.heightAnchor.constraint(equalToConstant: 20.0),
            
            location.topAnchor.constraint(equalTo: occupation.bottomAnchor, constant: Const.marginEight / 2.0),
            location.centerXAnchor.constraint(equalTo: centerXAnchor),
            location.widthAnchor.constraint(equalTo: widthAnchor),
            location.heightAnchor.constraint(equalToConstant: 20.0)
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
        self.location.text = "From " + text
    }
    
    // Sets profile image, default: profileImageTemplate
    func setProfileImage(image: UIImage) {
        self.profileImage.image = image.withRenderingMode(.alwaysOriginal)
    }
}
