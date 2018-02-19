//
//  SignUpController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift

class SignUpController: UIViewController {
    
    // Custom initializers
    let logo: UIImageView = {
        let i = UIImageView(image: #imageLiteral(resourceName: "TEDxISTAlameda-black"))
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
    
    let sectionTitle: UILabel = {
        let st = UILabel()
        st.textColor = .secondary
        st.text = "Sign up"
        st.font = UIFont.boldSystemFont(ofSize: Const.titleFontSize)
        return st
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email address", attributes: [NSAttributedStringKey.foregroundColor: UIColor.secondary.withAlphaComponent(0.6)])
        tf.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    var borderEmail: CALayer! = nil
    
    let errorEmail: UILabel = {
        let tf = UILabel()
        tf.text = ""
        tf.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        tf.textColor = .primary
        return tf
    }()
    
    let ticketTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Ticket reference", attributes: [NSAttributedStringKey.foregroundColor: UIColor.secondary.withAlphaComponent(0.6)])
        tf.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    var borderTicket: CALayer! = nil
    
    let errorTicket: UILabel = {
        let tf = UILabel()
        tf.text = ""
        tf.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        tf.textColor = .primary
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
        b.setTitle("Let's do this!", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.alpha = 1
        b.isEnabled = true
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = .background
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = .white
        
        // Logo
        view.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Const.marginAnchorsToContent * 3),
            logo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Const.marginAnchorsToContent),
        ])
        
        // Add email & ticket reference
        [sectionTitle, emailTextField, errorEmail, ticketTextField, errorTicket].forEach( {stackView.addArrangedSubview($0)} )
        stackView.setCustomSpacing(Const.marginAnchorsToContent * 1.5, after: sectionTitle)
        stackView.setCustomSpacing(Const.marginAnchorsToContent * 0.5, after: errorEmail)
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: Const.marginAnchorsToContent * 4),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -Const.marginAnchorsToContent * 2)
        ])
        
        // Login button
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Const.marginAnchorsToContent * 1.5),
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            loginButton.widthAnchor.constraint(equalToConstant: 150)
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
            supportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginAnchorsToContent),
            supportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Const.marginAnchorsToContent),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        
        // Email's bottom border
        borderEmail = CALayer()
        borderEmail.frame = CGRect(x: 0, y: emailTextField.frame.size.height - 2.0, width: emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        borderEmail.borderWidth = 2.0
        errorEmail.text!.isEmpty ? ( borderEmail.borderColor = UIColor.black.cgColor ) : ( borderEmail.borderColor = UIColor.red.cgColor )
        emailTextField.layer.addSublayer(borderEmail)
        emailTextField.layer.masksToBounds = true
        
        // Ticket's bottom border
        borderTicket = CALayer()
        borderTicket.frame = CGRect(x: 0, y: ticketTextField.frame.size.height - 2.0, width: ticketTextField.frame.size.width, height: ticketTextField.frame.size.height)
        borderTicket.borderWidth = 2.0
        errorTicket.text!.isEmpty ? ( borderTicket.borderColor = UIColor.black.cgColor ) : ( borderTicket.borderColor = UIColor.red.cgColor )
        ticketTextField.layer.addSublayer(borderTicket)
        ticketTextField.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
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
    
    // Handles login, whether is a new user or an existing one
    @objc func handleLogin() {
        
        guard let email = emailTextField.text, let ticket = ticketTextField.text else { return }
        self.errorTicket.text = ""
        self.errorEmail.text = ""
        self.showLoadingInButton() // Activity indicator shows up
        
        
        // Presents an alert to the user informing the network is unreachable
        if !ReachabilityManager.shared.reachability.isReachable {
            
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
                self.errorTicket.text = "Ticket reference has 6 characters. Try again?"
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
                    self.pushExistingUserToViewController() // If login is successful, sends user to ViewController, depending on isProfiled() boolean
                })
                
            default:
                print("Error: \(String(describing: errCode))")
            }
            
            self.hideLoadingInButton() // Activity indicator is hidden
            
        }) {
            
            UserDefaults.standard.setIsProfiled(value: false)
            self.pushNewUserToProfilingController() // If user creation is successful, sends user to ProfilingController
        }
    }
    
    // Sends user to the next ViewController with custom transition
    private func pushExistingUserToViewController() {
        
        let controller: UIViewController
        
        if UserDefaults.standard.isProfiled() {
            controller = TabBarController()
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
            present(controller, animated: false, completion: nil)
        } else {
            
            pushNewUserToProfilingController()
        }
    }
    
    private func pushNewUserToProfilingController() {
        
        let controller = ProfilingController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
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
        
        loginButton.setTitle("Let's do this!", for: .normal)
        loginButton.isEnabled = true
        activityIndicator.isHidden = true
    }
}

// Making LoginController to conform to NetworkStatusListener protocol
extension SignUpController: NetworkStatusListener {
    
    public func networkStatusDidChange(status: Reachability.NetworkStatus) {
        
        if status == .notReachable {
            
            DispatchQueue.main.async {
                self.loginButton.isEnabled = false
                self.loginButton.alpha = 0.4
            }
            
            // Presents an alert to the user informing the network is unreachable
            let alertController = UIAlertController(title: "No internet connection", message: "It seems you are not connected to the internet. Please enable Wifi or Cellular data, and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            DispatchQueue.main.async {
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1
            }
        }
    }
}
