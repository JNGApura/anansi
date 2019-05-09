//
//  ReportConfirmationView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 04/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ReportConfirmationView: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Custom initializers
    let backgroundView : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        v.isOpaque = false
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var user : User? {
        didSet {
            if let profileImageURL = user?.getValue(forField: .profileImageURL) as? String {
                userProfileImage.setImage(with: profileImageURL)
            }
        }
    }
    
    let reportedGroup: UIView = {
        let u = UIView()
        u.translatesAutoresizingMaskIntoConstraints = false
        return u
    }()
    
    let reportedBox: UIView = {
        let u = UIView()
        u.layer.borderColor = UIColor.primary.cgColor
        u.layer.borderWidth = 8
        u.layer.cornerRadius = 12
        u.layer.masksToBounds = true
        u.backgroundColor = .clear
        u.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 3 / 180)
        u.alpha = 0.0
        u.translatesAutoresizingMaskIntoConstraints = false
        return u
    }()
    
    let reportedLabel: UILabel = {
        let l = UILabel()
        l.text = "Reported".uppercased()
        l.textColor = .primary
        l.font = UIFont.boldSystemFont(ofSize: 44.0)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let userProfileImage: UIImageView = {
        let i = UIImageView()
        i.layer.cornerRadius = 64
        i.layer.masksToBounds = true
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let feedbackText: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.text = "Thank you for your feedback!\nWe'll take it from here."
        l.textColor = .background
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0.5, alignment: .center)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [backgroundView, reportedGroup].forEach( {view.addSubview($0)} )
        [userProfileImage, reportedBox, feedbackText].forEach( {reportedGroup.addSubview($0)} )
        reportedBox.addSubview(reportedLabel)
        
        // In bottom-up order
        NSLayoutConstraint.activate([
            
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            reportedGroup.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            reportedGroup.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -108.0),
            reportedGroup.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, constant: Const.marginSafeArea * 2.0),
            
            userProfileImage.topAnchor.constraint(equalTo: reportedGroup.topAnchor),
            userProfileImage.centerXAnchor.constraint(equalTo: reportedGroup.centerXAnchor),
            userProfileImage.widthAnchor.constraint(equalToConstant: 128.0),
            userProfileImage.heightAnchor.constraint(equalToConstant: 128.0),
            
            feedbackText.topAnchor.constraint(equalTo: userProfileImage.bottomAnchor, constant: 26.0),
            feedbackText.centerXAnchor.constraint(equalTo: reportedGroup.centerXAnchor),
            feedbackText.widthAnchor.constraint(equalTo: reportedGroup.widthAnchor),
            
            reportedBox.centerYAnchor.constraint(equalTo: userProfileImage.centerYAnchor),
            reportedBox.centerXAnchor.constraint(equalTo: userProfileImage.centerXAnchor),
            reportedBox.widthAnchor.constraint(equalToConstant: 275.0),
            reportedBox.heightAnchor.constraint(equalToConstant: 90.0),
            
            reportedLabel.centerYAnchor.constraint(equalTo: reportedBox.centerYAnchor),
            reportedLabel.centerXAnchor.constraint(equalTo: reportedBox.centerXAnchor),
            reportedLabel.heightAnchor.constraint(equalToConstant: 50.0),
            reportedLabel.widthAnchor.constraint(equalToConstant: 235.0),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.reportedBox.alpha = 1.0
        }, completion: nil)
        
        // Dismiss view after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    // MARK: - Custom functions
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}
