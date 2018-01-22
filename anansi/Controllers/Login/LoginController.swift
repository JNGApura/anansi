//
//  LoginController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    // Custom initializers
    
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
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .white
        
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
        
        // Activity indicator (in login button)
        
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
        
        // Email's bottom border
        borderEmail = CALayer()
        borderEmail.frame = CGRect(x: 0, y: emailTextField.frame.size.height - 2.0, width: emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        borderEmail.borderWidth = 2.0
        errorEmail.text!.isEmpty ? ( borderEmail.borderColor = UIColor.white.cgColor ) : ( borderEmail.borderColor = UIColor.red.cgColor )
        emailTextField.layer.addSublayer(borderEmail)
        emailTextField.layer.masksToBounds = true
        
        // Ticket's bottom border
        borderTicket = CALayer()
        borderTicket.frame = CGRect(x: 0, y: ticketTextField.frame.size.height - 2.0, width: ticketTextField.frame.size.width, height: ticketTextField.frame.size.height)
        borderTicket.borderWidth = 2.0
        errorTicket.text!.isEmpty ? ( borderTicket.borderColor = UIColor.white.cgColor ) : ( borderTicket.borderColor = UIColor.red.cgColor )
        ticketTextField.layer.addSublayer(borderTicket)
        ticketTextField.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    // White status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    // Handles login, whether is a new user or an existing one
    @objc func handleLogin() {
        
        guard let email = emailTextField.text, let ticket = ticketTextField.text else { return }
        self.errorTicket.text = ""
        self.errorEmail.text = ""
        self.showLoadingInButton() // Activity indicator shows up
        
        // Checks if the user is connected to internet
        if !Reachability.isConnectedToNetwork(){
            self.hideLoadingInButton()
            
            let alertController = UIAlertController(title: "No internet connection", message: "It seems you are not connected to the internet. Please enable Wifi or Cellular data, and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // All authentificatin is handled by NetworkManager.
        // createUser creates a new user, unless email is in incorrect format or ticket does not have 6 characters.
        // login signs in the user, unless ticket reference doesn't match or email doesn't match
        NetworkManager.shared.createUser(email: email, ticket: ticket, onFail: { (errCode) in
            
            switch errCode {
            case .invalidEmail:
                self.errorEmail.text = "Your email has an incorrect format. Try again?"
                
            case .weakPassword:
                self.errorTicket.text = "Ticket reference should have 6 characters. Try again?"
                if email == "" {
                    self.errorEmail.text = "Your email has an incorrect format. Try again?"
                }
                
            case .emailAlreadyInUse:
                
                NetworkManager.shared.login(email: email, ticket: ticket, onFail: { (errorCode) in
                    
                    switch errorCode {
                    case .wrongPassword:
                        self.errorTicket.text = "Your ticket reference doesn't match. Try again?"
                        
                    case .invalidEmail:
                        self.errorEmail.text = "Your email doesn't match. Try again?"
                        
                    default:
                        print("Error: \(String(describing: errorCode))")
                    }
                    
                }, onSuccess: {
                    self.pushTabBarController() // If login is successful, sends user to TabBarController
                })
                
            default:
                print("Error: \(String(describing: errCode))")
            }
            
            self.hideLoadingInButton() // Activity indicator is hidden
            
        }) {
            self.pushTabBarController() // If user creation is successful, sends user to TabBarController
        }
    }

    // Sends user to TabBarController with custom transition
    private func pushTabBarController() {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        let controller = TabBarController()
        present(controller, animated: false, completion: nil)
    }
    
    // Show activity indicator (spinner)
    private func showLoadingInButton() {
        
        loginButton.setTitle("", for: .normal)
        loginButton.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // Hides activity indicator (spinner)
    private func hideLoadingInButton() {
        
        loginButton.setTitle("Log into your account", for: .normal)
        loginButton.isEnabled = true
        activityIndicator.isHidden = true
    }
}
