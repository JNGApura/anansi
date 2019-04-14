//
//  SignUpController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift

class SignUpController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    // Custom initializers
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let logo: UIImageView = {
        let i = UIImageView(image: UIImage(named: "TEDxULisboa-black"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    let typingView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let sectionTitle: UILabel = {
        let st = UILabel()
        st.textColor = .secondary
        st.text = "Sign up"
        st.font = UIFont.boldSystemFont(ofSize: Const.titleFontSize)
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    lazy var emailText: UITextView = {
        let tf = UITextView()
        tf.text = "Email address"
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2, left: -6, bottom: -2, right: 0)
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    let borderEmail: UIView = {
        let b = UIView()
        b.backgroundColor = .secondary
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let errorEmail: UILabel = {
        let tf = UILabel()
        tf.text = ""
        tf.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        tf.textColor = .primary
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var ticketText: UITextView = {
        let tf = UITextView()
        tf.text = "Ticket reference"
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2, left: -6, bottom: -2, right: 0)
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    let borderTicket: UIView = {
        let b = UIView()
        b.backgroundColor = .secondary
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let errorTicket: UILabel = {
        let tf = UILabel()
        tf.text = ""
        tf.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        tf.textColor = .primary
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var loginButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Let's do this!", for: .normal)
        b.alpha = 1
        b.isEnabled = true
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = .background
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
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
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // Logo
        scrollView.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Const.marginSafeArea * 3),
            logo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Const.marginSafeArea),
        ])
        
        // Add email & ticket reference
        scrollView.addSubview(typingView)
        [sectionTitle, emailText, errorEmail, borderEmail, ticketText, errorTicket, borderTicket].forEach( {typingView.addSubview($0)} )
        NSLayoutConstraint.activate([
            typingView.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: Const.marginSafeArea * 3.5),
            typingView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            typingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Const.marginSafeArea * 2),
            typingView.heightAnchor.constraint(equalToConstant: 172.0),
            
            sectionTitle.topAnchor.constraint(equalTo: typingView.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            sectionTitle.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            sectionTitle.heightAnchor.constraint(equalToConstant: 26.0),
            
            emailText.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 30.0),
            emailText.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            emailText.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            emailText.heightAnchor.constraint(equalToConstant: 26.0),
            
            borderEmail.topAnchor.constraint(equalTo: emailText.bottomAnchor, constant: 2.0),
            borderEmail.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            borderEmail.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            borderEmail.heightAnchor.constraint(equalToConstant: 2.0),
            
            errorEmail.topAnchor.constraint(equalTo: borderEmail.bottomAnchor, constant: 4.0),
            errorEmail.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            errorEmail.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            errorEmail.heightAnchor.constraint(equalToConstant: 16.0),
            
            ticketText.topAnchor.constraint(equalTo: errorEmail.bottomAnchor, constant: 26.0),
            ticketText.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            ticketText.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            ticketText.heightAnchor.constraint(equalToConstant: 26.0),
            
            borderTicket.topAnchor.constraint(equalTo: ticketText.bottomAnchor, constant: 2.0),
            borderTicket.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            borderTicket.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            borderTicket.heightAnchor.constraint(equalToConstant: 2.0),
            
            errorTicket.topAnchor.constraint(equalTo: borderTicket.bottomAnchor, constant: 4.0),
            errorTicket.leadingAnchor.constraint(equalTo: typingView.leadingAnchor),
            errorTicket.trailingAnchor.constraint(equalTo: typingView.trailingAnchor),
            errorTicket.heightAnchor.constraint(equalToConstant: 16.0),
        ])
        
        // Login button
        scrollView.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: typingView.bottomAnchor, constant: Const.marginSafeArea * 2.0),
            loginButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
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
        scrollView.addSubview(supportButton)
        NSLayoutConstraint.activate([
            supportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginSafeArea),
            supportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Const.marginSafeArea),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom functions
    
    // Send to messenger (support)
    @objc func sendToMessenger() {
        
        let url = URL(string: "fb-messenger://user-thread/tedxistalameda")!
        
        UIApplication.shared.open(url, options: [:]) { (success) in
            
            if success == false {
                
                let url = URL(string: "https://m.me/tedxistalameda")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!)
                }
            }
        }
    }
    
    var currentPos : CGFloat! = 0
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            if activeText != nil {
                
                let activeTextRelativeMaxY = (activeText.frame.maxY + typingView.frame.origin.y - scrollView.contentOffset.y)
                let screenHeight = view.frame.height
                
                if (screenHeight - activeTextRelativeMaxY - 24) < keyboardHeight {
                    
                    scrollView.frame.origin.y -= keyboardHeight - (screenHeight - activeTextRelativeMaxY - 24)
                    view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.2) {
            self.scrollView.frame.origin.y = 0
        }
    }
    
    // MARK: UITextViewDelegate
    
    var activeText: UITextView!
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        activeText = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == emailText {
            
            borderEmail.backgroundColor = .primary
            
            if textView.text == "Email address" {
                textView.text = ""
            }
        }
        
        if textView == ticketText {
            borderTicket.backgroundColor = .primary
            
            if textView.text == "Ticket reference" {
                textView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        activeText = nil
        
        if textView == emailText {
            borderEmail.backgroundColor = .secondary
            
            if textView.text == "" {
                textView.text = "Email address"
            }
        }
        
        if textView == ticketText {
            borderTicket.backgroundColor = .secondary
            
            if textView.text == "" {
                textView.text = "Ticket reference"
            }
        }
    }
    
    // MARK: Network
    
    // Handles login, whether is a new user or an existing one
    @objc func handleLogin() {
        
        guard let email = emailText.text, let ticket = ticketText.text else { return }
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
                self.borderEmail.backgroundColor = .primary
                
            case .weakPassword:
                self.errorTicket.text = "Ticket reference has 6 characters. Try again?"
                self.borderTicket.backgroundColor = .primary
                if email == "" {
                    self.errorEmail.text = "Your email has an incorrect format. Try again?"
                    self.borderEmail.backgroundColor = .primary
                }
                
            case .emailAlreadyInUse:
                
                NetworkManager.shared.login(email: email, ticket: ticket, onFail: { (errorCode) in
                    
                    switch errorCode {
                    case .wrongPassword:
                        self.errorTicket.text = "Your ticket reference doesn't match. Try again?"
                        self.borderTicket.backgroundColor = .primary
                        
                    case .invalidEmail:
                        self.errorEmail.text = "Your email doesn't match. Try again?"
                        self.borderEmail.backgroundColor = .primary
                        
                    default:
                        print("Error: \(String(describing: errorCode))")
                    }
                    
                }, onSuccess: {
                    self.pushExistingUserToViewController() // If login is successful, sends user to ViewController, depending on if data is already on DB
                })
                
            default:
                print("Error: \(String(describing: errCode))")
            }
            
            self.hideLoadingInButton() // Activity indicator is hidden
            
        }) {
            
            self.pushNewUserToProfilingController() // If user creation is successful, sends user to ProfilingController
        }
    }
    
    // Sends user to the next ViewController with custom transition
    private func pushExistingUserToViewController() {
        
        let myID = NetworkManager.shared.getUID()
        
        NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
            let email = dictionary["email"] as? String
            
            if email != nil {
                
                // Recurring users might have changed phone, so UserDefaults (LoggedIn & Profiled) need ot be updated to true
                UserDefaults.standard.setLoggedIn(value: true)
                UserDefaults.standard.setProfiled(value: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    let controller = TabBarController()
                    controller.modalPresentationStyle = .overFullScreen
                    controller.modalTransitionStyle = .crossDissolve
                    self.present(controller, animated: true, completion: nil)
                }
                
            } else {
                
                self.pushNewUserToProfilingController()
            }
        }
    }
    
    private func pushNewUserToProfilingController() {
        
        UserDefaults.standard.setLoggedIn(value: true)
        UserDefaults.standard.setProfiled(value: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            let controller = ProfilingController()
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
            
        }
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
