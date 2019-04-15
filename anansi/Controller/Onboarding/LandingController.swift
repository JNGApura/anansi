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
        let i = UIImageView(image: UIImage(named: "TEDxULisboa-black"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    let pageTitle: UILabel = {
        let t = UILabel()
        t.text = "We're very excited you are here!"
        t.formatTextWithLineSpacing(lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0, alignment: .left)
        t.textColor = .primary
        t.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        t.lineBreakMode = .byWordWrapping
        t.numberOfLines = 0
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let pageDescription: UILabel = {
        let t = UILabel()
        t.text = "This app is exclusive for TEDxULisboa 2019 attendees. Please make sure you have a ticket."
        t.formatTextWithLineSpacing(lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0, alignment: .left)
        t.textColor = .secondary
        t.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        t.lineBreakMode = .byWordWrapping
        t.numberOfLines = 0
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let wantsTicketButton: TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("How do I get a ticket?", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.addTarget(self, action: #selector(sendToFever), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let hasTicketReferenceButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("I have a ticket reference", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(toSignUp), for: .touchUpInside)
        return b
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Set up constraint constants according to iphone height | use case: motherf*cker iphone5
        if Display.typeIsLike == .iphone5 {
            pageTitle.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1.1, hyphenation: 0, alignment: .left)
            pageDescription.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1.1, hyphenation: 0, alignment: .left)
        }
        
        [logo, pageTitle, pageDescription, hasTicketReferenceButton, wantsTicketButton].forEach { view.addSubview($0) }
        
        // Logo
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Const.marginSafeArea * 2.0),
            logo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Const.marginSafeArea),
            
            pageTitle.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: Const.marginSafeArea * 2.0),
            pageTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageTitle.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            
            pageDescription.topAnchor.constraint(equalTo: pageTitle.bottomAnchor),
            pageDescription.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageDescription.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            
            wantsTicketButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginSafeArea),
            wantsTicketButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            wantsTicketButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            wantsTicketButton.widthAnchor.constraint(equalToConstant: 246.0),
            
            hasTicketReferenceButton.bottomAnchor.constraint(equalTo: wantsTicketButton.topAnchor, constant: -16.0),
            hasTicketReferenceButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            hasTicketReferenceButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            hasTicketReferenceButton.widthAnchor.constraint(equalToConstant: 246.0)
        ])
        
        // Sets "isOnboarded" to true in UserDefaults
        //UserDefaults.standard.setOnboarded(value: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom functions
    
    // Send to FeverUp website
    @objc func sendToFever() {
        
        let url = URL(string: "https://www.feverup.com/m/72092/?ref=6405")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    // Sends user to SignUpController with custom transition
    @objc func toSignUp() {
        
        let controller = EventViewController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        let navController = UINavigationController(rootViewController: controller)
        navController.setNavigationBarHidden(false, animated: false)
        self.present(navController, animated: true, completion: nil)
        
        /*
        let controller = SignUpController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)*/
    }
}
