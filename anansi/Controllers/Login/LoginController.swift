//
//  LoginController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {
    
    let backgroundImage: UIImageView = {
        let i = UIImageView(image: #imageLiteral(resourceName: "attendees-bw"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        return i
    }()
    
    let logo: UIImageView = {
        let i = UIImageView(image: #imageLiteral(resourceName: "logo-white"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    let supportButton: TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("Need help?", for: .normal)
        b.setTitleColor(Color.background, for: .normal)
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(sendToMessenger), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let sectionTitle: UILabel = {
        let st = UILabel()
        st.textColor = Color.background
        st.text = "Log in"
        st.font = UIFont.boldSystemFont(ofSize: 24.0)
        return st
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email address", attributes: [NSAttributedStringKey.foregroundColor: Color.background.withAlphaComponent(0.6)])
        tf.font = UIFont.boldSystemFont(ofSize: 17)
        tf.textColor = Color.background
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    var borderEmail: CALayer! = nil
    
    let errorEmail: UILabel = {
        let tf = UILabel()
        tf.text = ""
        tf.font = UIFont.boldSystemFont(ofSize: 13)
        tf.textColor = Color.primary
        return tf
    }()
    
    let ticketTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Ticket reference", attributes: [NSAttributedStringKey.foregroundColor: Color.background.withAlphaComponent(0.6)])
        tf.font = UIFont.boldSystemFont(ofSize: 17)
        tf.textColor = Color.background
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    var borderTicket: CALayer! = nil
    
    let errorTicket: UILabel = {
        let tf = UILabel()
        tf.text = ""
        tf.font = UIFont.boldSystemFont(ofSize: 13)
        tf.textColor = Color.primary
        return tf
    }()
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    lazy var loginButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Log into your account", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.alpha = 1
        b.isEnabled = true
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = Color.background
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Background image
        
        view.addSubview(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImage.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        // Gradient
        
        let layer = CAGradientLayer()
        layer.frame = view.layer.frame
        layer.colors = [UIColor.black.withAlphaComponent(0.84).cgColor, UIColor.black.withAlphaComponent(0.54).cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        view.layer.addSublayer(layer)
        
        // Logo
        
        view.addSubview(logo)
        
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60.0),
            logo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
        ])
        
        // Add email & ticket reference
        stackView.addArrangedSubview(sectionTitle)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(errorEmail)
        stackView.addArrangedSubview(ticketTextField)
        stackView.addArrangedSubview(errorTicket)
        
        stackView.setCustomSpacing(30.0, after: sectionTitle)
        stackView.setCustomSpacing(10.0, after: errorEmail)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -35.0),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -40.0)
        ])
        
        // Login button
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30.0),
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48.0),
            loginButton.widthAnchor.constraint(equalToConstant: 220.0)
        ])
        
        // Acitvity indicator in login button
        
        loginButton.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
        ])
        
        // Support button
        view.addSubview(supportButton)
        
        NSLayoutConstraint.activate([
            supportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0),
            supportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0),
        ])
        
        // Sets "isOnboarded" to true in UserDefaults
        UserDefaults.standard.setIsOnboarded(value: true)
    }
    
    override func viewDidLayoutSubviews() {
        
        borderEmail = CALayer()
        borderEmail.frame = CGRect(x: 0, y: emailTextField.frame.size.height - 2.0, width: emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        borderEmail.borderWidth = 2.0
        if errorEmail.text == "" {
            borderEmail.borderColor = UIColor.white.cgColor
        } else {
            borderEmail.borderColor = UIColor.red.cgColor
        }
        
        emailTextField.layer.addSublayer(borderEmail)
        emailTextField.layer.masksToBounds = true
        
        borderTicket = CALayer()
        borderTicket.frame = CGRect(x: 0, y: ticketTextField.frame.size.height - 2.0, width: ticketTextField.frame.size.width, height: ticketTextField.frame.size.height)
        borderTicket.borderWidth = 2.0
        if errorTicket.text == "" {
            borderTicket.borderColor = UIColor.white.cgColor
        } else {
            borderTicket.borderColor = UIColor.red.cgColor
        }
        
        ticketTextField.layer.addSublayer(borderTicket)
        ticketTextField.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func sendToMessenger() {
        
        let url = URL(string: "https://www.messenger.com/t/tedxistalameda")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func handleLogin() {
        
        guard let email = emailTextField.text, let password = ticketTextField.text else { return }
        
        self.showLoadingInButton()
        
        if !Reachability.isConnectedToNetwork(){
            self.hideLoadingInButton()
            
            let alertController = UIAlertController(title: "No internet connection", message: "It seems you are not connected to the internet. Please enable Wifi or Cellular data, and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        self.errorTicket.text = ""
        self.errorEmail.text = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { (existingUser, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                
                switch errorCode {
                case .userNotFound:
                    
                    Auth.auth().createUser(withEmail: email, password: password) { (newUser, err) in
                        if err != nil, let errCode = AuthErrorCode(rawValue: err!._code) {
                            
                            self.hideLoadingInButton()
                            
                            switch errCode {
                            case .invalidEmail:
                                self.errorEmail.text = "Please confirm your email address"
                                
                            case .weakPassword:
                                self.errorTicket.text = "Ticket reference should have 6 characters"
                                
                            default:
                                print("Error: \(String(describing: err))")
                            }
                            return
                        }
                        
                        guard let uid = newUser?.uid else { return }
                        
                        // Successfully authenticated user
                        let databaseReference = Database.database().reference()
                        let usersReference = databaseReference.child("users").child(uid)
                        usersReference.updateChildValues([
                            "email" : email,
                            "ticket reference" : password
                            ], withCompletionBlock: { (erro, usersReference) in
                                if erro != nil {
                                    print(erro!.localizedDescription)
                                    self.hideLoadingInButton()
                                    return
                                }
                                
                                self.errorEmail.text = ""
                                self.errorTicket.text = ""
                                self.pushTabBarController()
                        })
                    }
                    
                case .invalidEmail:
                    self.hideLoadingInButton()
                    self.errorEmail.text = "Please confirm your email address"
                    
                case .wrongPassword:
                    self.hideLoadingInButton()
                    self.errorTicket.text = "Please confirm your ticket reference"
                    
                default:
                    self.hideLoadingInButton()
                    print("Error: \(String(describing: error))")
                }
                return
            }
            
            self.errorEmail.text = ""
            self.errorTicket.text = ""
            self.pushTabBarController()
        }
    }
    
    func pushTabBarController() {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        let controller = TabBarController()
        present(controller, animated: false, completion: nil)
    }
    
    func showLoadingInButton() {
        
        loginButton.setTitle("", for: .normal)
        loginButton.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingInButton() {
        
        loginButton.setTitle("Log into your account", for: .normal)
        loginButton.isEnabled = true
        activityIndicator.isHidden = true
    }
}
