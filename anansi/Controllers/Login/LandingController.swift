//
//  LandingController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift

class LandingController: UIViewController {
    
    // Custom initializers
    let logo: UIImageView = {
        let i = UIImageView(image: #imageLiteral(resourceName: "logo-white"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    let supportButton: TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("Need help?", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(sendToMessenger), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let descriptionText = "<style>*{font-family:\"Avenir-Roman\"; font-size: 17px}</style><p>This app is currently only available to attendees of TEDxISTAlameda 2018 conference. If you are looking for TED on your mobile device, check out <a href=\"https://itunes.apple.com/us/app/ted/id376183339\">this app</a>.</p></body>"

    lazy var pageDescription: UITextView = {
        let text = UITextView()
        text.textContainerInset = UIEdgeInsetsMake(8.0, -4.0, 8.0, -4.0) // top, left, bottom, right
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.isEditable = false
        text.formatHTMLText(htmlText: descriptionText, lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0, alignment: .left)
        return text
    }()
    
    lazy var hasTicketReferenceButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("I have a ticket reference", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.alpha = 1
        b.isEnabled = true
        b.addTarget(self, action: #selector(sendUserToSignUpPage), for: .touchUpInside)
        return b
    }()
    
    lazy var wantsTicketButton: SecondaryButton = {
        let b = SecondaryButton()
        b.setTitle("How do I get a ticket?", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.alpha = 1
        b.isEnabled = true
        b.addTarget(self, action: #selector(sendUserToGetTicket), for: .touchUpInside)
        return b
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Set up constraint constants according to iphone height | use case: motherf*cker iphone5
        let spacingTopLogo: CGFloat
        let spacingLogoDescription: CGFloat
        
        if Display.typeIsLike == .iphone5 {
            spacingTopLogo = Const.marginAnchorsToContent * 2.0
            spacingLogoDescription = Const.marginAnchorsToContent * 2.0
            pageDescription.formatHTMLText(htmlText: descriptionText, lineSpacing: 8, lineHeightMultiple: 1.1, hyphenation: 0, alignment: .left)
        
        } else {
            spacingTopLogo = Const.marginAnchorsToContent * 3.0
            spacingLogoDescription = Const.marginAnchorsToContent * 4.0
        }
        
        // Logo
        view.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: spacingTopLogo),
            logo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Const.marginAnchorsToContent),
        ])
        
        // Description text
        view.addSubview(pageDescription)
        NSLayoutConstraint.activate([
            pageDescription.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: spacingLogoDescription),
            pageDescription.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageDescription.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Const.marginAnchorsToContent * 2.0),
            //pageDescription.heightAnchor.constraint(equalToConstant: 205.0)
        ])
        
        // hasTicketReferenceButton button
        view.addSubview(hasTicketReferenceButton)
        NSLayoutConstraint.activate([
            hasTicketReferenceButton.topAnchor.constraint(equalTo: pageDescription.bottomAnchor, constant: Const.marginAnchorsToContent * 1.5),
            hasTicketReferenceButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            hasTicketReferenceButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            hasTicketReferenceButton.widthAnchor.constraint(equalToConstant: 246.0)
        ])
        
        // wantsTicketButton button
        view.addSubview(wantsTicketButton)
        NSLayoutConstraint.activate([
            wantsTicketButton.topAnchor.constraint(equalTo: hasTicketReferenceButton.bottomAnchor, constant: 16.0),
            wantsTicketButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            wantsTicketButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            wantsTicketButton.widthAnchor.constraint(equalToConstant: 246.0)
        ])
        
        // Support button
        view.addSubview(supportButton)
        NSLayoutConstraint.activate([
            supportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginAnchorsToContent),
            supportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Const.marginAnchorsToContent),
        ])
        
        // Sets "isOnboarded" to true in UserDefaults
        UserDefaults.standard.setIsOnboarded(value: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom functions
    
    // Send to messenger (support)
    @objc func sendToMessenger() {
        
        let url = URL(string: "https://www.messenger.com/t/tedxistalameda")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // Sends user to SignUpController with custom transition
    @objc func sendUserToSignUpPage() {
    
        let controller = SignUpController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
    }
    
    // Sends user to get a ticket (outside app) // TO DO!
    @objc func sendUserToGetTicket() {
        
        let url = URL(string: "https://www.messenger.com/t/tedxistalameda")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}
