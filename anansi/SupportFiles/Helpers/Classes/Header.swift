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
        return view
    }()
    
    let headerBottomBorder: UIView = {
        let view = UIView()
        view.isOpaque = true
        view.backgroundColor = .primary
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

            headerBottomBorder.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: Const.marginEight),
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
    
    let participantTypeBox: LabelWithInsets = {
        let view = LabelWithInsets()
        view.text = "Participant"
        view.textColor = .secondary
        view.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.backgroundColor = .background
        view.isOpaque = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "profileImage").withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = Const.profileImageHeight / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Adds participantTypeBox and profileImage
        [participantTypeBox, profileImage].forEach( {addSubview($0)} )
        
        // Adds layout constraints
        NSLayoutConstraint.activate([
            
            participantTypeBox.topAnchor.constraint(equalTo: topAnchor, constant: 80.0),
            participantTypeBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -15.0),
            participantTypeBox.widthAnchor.constraint(equalToConstant: 135.0),
            participantTypeBox.heightAnchor.constraint(equalToConstant: 30.0),
            
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
        self.participantTypeBox.text = type
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
