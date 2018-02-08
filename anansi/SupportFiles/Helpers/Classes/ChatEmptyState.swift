//
//  ChatEmptyState.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatEmptyState: UIView {
    
    var chatLogController: ChatLogController? {
        didSet {
            
            self.user = chatLogController?.user
            waveButton.addTarget(chatLogController, action: #selector(ChatLogController.sendWave), for: .touchUpInside)
        }
    }
    
    var user: User?
    
    let profileView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let topSeparatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let bottomSeparatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 80 / 2
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let userName: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: Const.headlineFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .left
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let userOccupation: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .left
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let userLocation: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .left
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel()
        l.text = "Start a chain(ge) (re)action with a wave!"
        l.textColor = .secondary
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let waveHandEmoji: UILabel = {
        let l = UILabel()
        l.text = "👋"
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 56.0)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let waveButton: UIButton = {
        let l = UIButton()
        l.setTitle("Wave", for: .normal)
        l.titleLabel?.textAlignment = .center
        l.titleLabel?.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.tintColor = .white
        l.backgroundColor = .primary
        l.layer.cornerRadius = 18
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .background
        
        // Add subviews
        [topSeparatorLine, userImageView, userName, userOccupation, userLocation, bottomSeparatorLine].forEach { profileView.addSubview($0) }
        [profileView, messageLabel, waveHandEmoji, waveButton].forEach { addSubview($0) }
        
        // Add layout constraints
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        // Set user's profile image
        if let userImage = user!.profileImageURL {
            userImageView.loadImageUsingCacheWithUrlString(userImage)
        }
        
        // Set user's name
        if let name = user!.name {
            userName.text = name
        }
        
        // Set user's title
        if let occupation = user!.occupation {
            userOccupation.text = occupation
        }
        
        // Set user's location
        if let location = user!.location {
            userLocation.text = "From " + location
        }
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            
            profileView.topAnchor.constraint(equalTo: topAnchor),
            profileView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileView.widthAnchor.constraint(equalTo: widthAnchor),
            profileView.heightAnchor.constraint(equalToConstant: 140.0),
            
            topSeparatorLine.topAnchor.constraint(equalTo: profileView.topAnchor),
            topSeparatorLine.leadingAnchor.constraint(equalTo: profileView.leadingAnchor),
            topSeparatorLine.widthAnchor.constraint(equalTo: profileView.widthAnchor),
            topSeparatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            userImageView.centerYAnchor.constraint(equalTo: profileView.centerYAnchor),
            userImageView.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 16.0),
            userImageView.widthAnchor.constraint(equalToConstant: 80.0),
            userImageView.heightAnchor.constraint(equalToConstant: 80.0),
            
            userName.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 32.0),
            userName.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16.0),
            userName.widthAnchor.constraint(equalTo: profileView.widthAnchor),
            userName.heightAnchor.constraint(equalToConstant: 30.0),
            
            userOccupation.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 4.0),
            userOccupation.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16.0),
            userOccupation.widthAnchor.constraint(equalTo: profileView.widthAnchor),
            userOccupation.heightAnchor.constraint(equalToConstant: 20.0),
            
            userLocation.topAnchor.constraint(equalTo: userOccupation.bottomAnchor, constant: 4.0),
            userLocation.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16.0),
            userLocation.widthAnchor.constraint(equalTo: profileView.widthAnchor),
            userLocation.heightAnchor.constraint(equalToConstant: 20.0),
            
            bottomSeparatorLine.bottomAnchor.constraint(equalTo: profileView.bottomAnchor),
            bottomSeparatorLine.leadingAnchor.constraint(equalTo: profileView.leadingAnchor),
            bottomSeparatorLine.widthAnchor.constraint(equalTo: profileView.widthAnchor),
            bottomSeparatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            messageLabel.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 30.0),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor),
            messageLabel.heightAnchor.constraint(equalToConstant: 20.0),
            
            waveHandEmoji.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20.0),
            waveHandEmoji.centerXAnchor.constraint(equalTo: centerXAnchor),
            waveHandEmoji.widthAnchor.constraint(equalTo: widthAnchor),
            waveHandEmoji.heightAnchor.constraint(equalToConstant: 64.0),
            
            waveButton.topAnchor.constraint(equalTo: waveHandEmoji.bottomAnchor, constant: 16.0),
            waveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            waveButton.widthAnchor.constraint(equalToConstant: 86.0),
            waveButton.heightAnchor.constraint(equalToConstant: 36.0),
        ])
    }
}
