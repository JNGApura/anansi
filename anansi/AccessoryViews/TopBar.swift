//
//  TopBar.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class TopBar : UIView {
    
    var statusbarHeight : CGFloat = 0.0 {
        didSet {
            statusbar.heightAnchor.constraint(equalToConstant: statusbarHeight).isActive = true
        }
    }
    
    var navigationbarHeight : CGFloat = 0.0 {
        didSet {
            navigationbar.heightAnchor.constraint(equalToConstant: navigationbarHeight).isActive = true
        }
    }
    
    lazy var statusbar : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.alpha = 0.0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var navigationbar : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.alpha = 0.0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let titleLabel: UILabel = {
        let t = UILabel()
        t.textColor = .secondary
        t.textAlignment = .center
        t.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let backButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .primary
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // Action button is hidden by default
    lazy var actionButton: UIButton = {
        let b = UIButton()
        b.tintColor = .secondary
        b.backgroundColor = .background
        b.layer.cornerRadius = 16.0
        b.layer.masksToBounds = true
        b.clipsToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add headerTitle and headerBottomBorder subviews
        [statusbar, navigationbar, titleLabel, backButton, actionButton].forEach { addSubview($0) }
        
        // Adds layout constraints
        NSLayoutConstraint.activate([
            
            statusbar.topAnchor.constraint(equalTo: topAnchor),
            statusbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            navigationbar.topAnchor.constraint(equalTo: statusbar.bottomAnchor),
            navigationbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: navigationbar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navigationbar.centerYAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: navigationbar.leadingAnchor, constant: Const.marginEight * 2.0 - 1.0),
            backButton.centerYAnchor.constraint(equalTo: navigationbar.centerYAnchor),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24.0),
            
            actionButton.trailingAnchor.constraint(equalTo: navigationbar.trailingAnchor, constant: -(Const.marginEight * 2.0)),
            actionButton.centerYAnchor.constraint(equalTo: navigationbar.centerYAnchor),
            actionButton.heightAnchor.constraint(equalTo: actionButton.widthAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 32.0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets topbar title
    func setTitle(name: String) {
        self.titleLabel.text = name
    }
    
    // Sets topbar title color, default: Color.secondary
    func setTitleColor(textColor: UIColor) {
        self.titleLabel.textColor = textColor
    }
    
    // Sets statusbar height
    func setStatusBarHeight(with height: CGFloat) {
        self.statusbarHeight = height
    }
    
    // Sets navigationbar height
    func setNavigationBarHeight(with height: CGFloat) {
        self.navigationbarHeight = height
    }
    
    // Adds background view + increases size of backbutton
    func setLargerBackButton() {
        
        backButton.backgroundColor = .background
        backButton.layer.cornerRadius = Const.navButtonHeight / 2.0
        backButton.clipsToBounds = true

        backButton.removeConstraints(self.backButton.constraints)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navigationbar.leadingAnchor, constant: Const.marginEight * 2.0),
            backButton.centerYAnchor.constraint(equalTo: navigationbar.centerYAnchor),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
            backButton.widthAnchor.constraint(equalToConstant: Const.navButtonHeight),
        ])
    }
    
    // Sets action button
    func setActionButton(with image: UIImage) {
        
        actionButton.setImage(image, for: .normal)
        actionButton.tintColor = .secondary
        actionButton.isHidden = false
    }
    
    // Sets modal style
    func setModalStyle() {
        
        backButton.isHidden = true
        
        actionButton.backgroundColor = UIColor.tertiary.withAlphaComponent(0.4)
    }
}
