//
//  SignUpController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SafariServices

class SignUpController: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    let defaults = UserDefaults.standard
    
    var currentPos : CGFloat! = 0
    
    var activeText: UITextView!
    
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
    
    // Stack view
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
        tf.delegate = self
        tf.text = "Email address"
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2, left: 4.0, bottom: -2, right: 4.0)
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
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
        tf.delegate = self
        tf.text = "Ticket reference"
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2, left: 4.0, bottom: -2, right: 4.0)
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
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
    
    // Stackview for disclaimer
    let disclaimer : UILabel = {
        let u = UILabel()
        u.text = "We will never share your data with a third party."
        u.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        u.textColor = .background
        u.numberOfLines = 0
        u.translatesAutoresizingMaskIntoConstraints = false
        return u
    }()
    
    lazy var termsButton : TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("Terms", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        b.addTarget(self, action: #selector(navigateToTerms), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    lazy var privacyButton : TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("Privacy", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        b.addTarget(self, action: #selector(navigateToPrivacy), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var disclaimerStackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Buttons
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
        b.setTitle("I need help", for: .normal)
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
        
        [termsButton, privacyButton, disclaimer].forEach { disclaimerStackView.addArrangedSubview($0)}
        stackView.setCustomSpacing(Const.marginEight * 1.5, after: termsButton)
        stackView.setCustomSpacing(Const.marginEight * 1.5, after: privacyButton)
        
        [sectionTitle, emailText, borderEmail, errorEmail, ticketText, borderTicket, errorTicket, disclaimerStackView].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSpacing(Const.marginSafeArea, after: sectionTitle)
        stackView.setCustomSpacing(1.0, after: emailText)
        stackView.setCustomSpacing(Const.marginEight / 2.0, after: borderEmail)
        stackView.setCustomSpacing(Const.marginSafeArea, after: errorEmail)
        stackView.setCustomSpacing(1.0, after: ticketText)
        stackView.setCustomSpacing(Const.marginEight / 2.0, after: borderTicket)
        stackView.setCustomSpacing(Const.marginEight * 2.0, after: errorTicket)
        
        [logo, stackView, loginButton, supportButton].forEach( { scrollView.addSubview($0) })

        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Const.marginSafeArea * 2.0),
            logo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Const.marginSafeArea),

            // stack view
            stackView.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: Const.marginSafeArea * 2.0),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Const.marginSafeArea * 2),
            //typingView.heightAnchor.constraint(equalToConstant: 172.0),
            
            sectionTitle.heightAnchor.constraint(equalToConstant: 32.0),
            emailText.heightAnchor.constraint(equalToConstant: 26.0),
            borderEmail.heightAnchor.constraint(equalToConstant: 1.0),
            errorEmail.heightAnchor.constraint(equalToConstant: 16.0),
            ticketText.heightAnchor.constraint(equalToConstant: 26.0),
            borderTicket.heightAnchor.constraint(equalToConstant: 1.0),
            errorTicket.heightAnchor.constraint(equalToConstant: 16.0),
            
            termsButton.widthAnchor.constraint(equalToConstant: 48.0),
            privacyButton.widthAnchor.constraint(equalToConstant: 56.0),
            
            // Login Button
            supportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginSafeArea),
            supportButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            supportButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            supportButton.widthAnchor.constraint(equalToConstant: 246.0),
            
            loginButton.bottomAnchor.constraint(equalTo: supportButton.topAnchor, constant: -16.0),
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: Const.buttonHeight),
            loginButton.widthAnchor.constraint(equalToConstant: 246.0)
        ])
        
        // Activity indicator (in login button)
        loginButton.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        if let url = URL(string: "fb-messenger://user-thread/tedxulisboa") {
            
            UIApplication.shared.open(url, options: [:]) { (result) in
                if !result {
                    
                    if let url = URL(string: "https://m.me/tedxulisboa") {
                        let vc = SFSafariViewController(url: url)
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
            
        hideLoadingInButton()
    }
    
    @objc func navigateToTerms() {
        
        // About - Terms & Conditions
        let termsPage = AboutPageView(id: "terms")
        let navController = UINavigationController(rootViewController: termsPage)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc func navigateToPrivacy() {
        
        // About - Privacy Policy
        if let url = URL(string: "https://tedxulisboa.com/privacy-policy.html") {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            if activeText != nil {
                
                let activeTextRelativeMaxY = (activeText.frame.maxY + stackView.frame.origin.y - scrollView.contentOffset.y)
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
    
    // MARK: Network
    
    // Handles login, whether is a new user or an existing one
    @objc func handleLogin() {
        
        guard let email = emailText.text, let ticket = ticketText.text else { return }
        self.errorTicket.text = ""
        self.errorEmail.text = ""
        self.showLoadingInButton() // Activity indicator shows up
        
        if email == "Email address" {
            self.errorEmail.text = "Your email has an incorrect format. Try again?"
            self.borderEmail.backgroundColor = .primary
            self.emailText.shake()
            self.borderEmail.shake()
            
            self.hideLoadingInButton() // Activity indicator is hidden
            
            return
        }
        
        if ticket.range(of: #"^([0-9]{7}|[0-9]{8})$"#, options: .regularExpression) == nil {
            self.errorTicket.text = "Ticket reference has 7 to 8 digits. Try again?"
            self.borderTicket.backgroundColor = .primary
            self.ticketText.shake()
            self.borderTicket.shake()
            
            self.hideLoadingInButton() // Activity indicator is hidden
            
            return
        }
        
        // Presents an alert to the user informing the network is unreachable
        if !ReachabilityManager.shared.reachability.isReachable {
            
            self.hideLoadingInButton()
            
            let alertController = UIAlertController(title: "No internet connection 😳", message: "We'll keep trying to reconnect. Meanwhile, could you please check your Wifi or Cellular data?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // All authentificatin is handled by NetworkManager.
        // createUser creates a new user, unless email is in incorrect format or ticket does not have 7 characters.
        // login signs in the user, unless ticket reference doesn't match or email doesn't match
        NetworkManager.shared.createUserInAuth(email: email, ticket: ticket, onFail: { (errCode) in
            
            switch errCode {
            case .invalidEmail:
                self.errorEmail.text = "Your email has an incorrect format. Try again?"
                self.borderEmail.backgroundColor = .primary
                self.emailText.shake()
                self.borderEmail.shake()
                
            case .weakPassword:
                self.errorTicket.text = "Ticket reference has 7 to 8 digits. Try again?"
                self.borderTicket.backgroundColor = .primary
                self.ticketText.shake()
                self.borderTicket.shake()
                
                if email == "" {
                    self.errorEmail.text = "Your email has an incorrect format. Try again?"
                    self.borderEmail.backgroundColor = .primary
                    self.emailText.shake()
                    self.borderEmail.shake()
                }
                
            case .emailAlreadyInUse:
                
                NetworkManager.shared.login(email: email, ticket: ticket, onFail: { (errorCode) in
                    
                    switch errorCode {
                    case .wrongPassword:
                        self.errorTicket.text = "Your ticket reference doesn't match. Try again?"
                        self.borderTicket.backgroundColor = .primary
                        self.ticketText.shake()
                        self.borderTicket.shake()
                        
                    case .invalidEmail:
                        self.errorEmail.text = "Your email doesn't match. Try again?"
                        self.borderEmail.backgroundColor = .primary
                        self.emailText.shake()
                        self.borderEmail.shake()
                        
                    default:
                        print("Error: \(String(describing: errorCode))")
                    }
                    
                    // If login is successful, sends user to ViewController, depending on if data is already on DB
                }, onSuccess: {
                    
                    self.defaults.set(email, forKey: "email")
                    self.defaults.set(ticket, forKey: "ticket")
                    self.defaults.synchronize()
                    
                    if let isEmailVerified = NetworkManager.shared.isEmailVerified() {
                        
                        if !isEmailVerified {
                            self.presentAlertWithEmailVerificationError()
                            
                        } else {
                            self.pushExistingUserToViewController()
                        }
                    }
                })
                
            default:
                print("Error: \(String(describing: errCode))")
            }
            
            self.hideLoadingInButton() // Activity indicator is hidden
            
        }) {
            
            self.defaults.set(email, forKey: "email")
            self.defaults.set(ticket, forKey: "ticket")
            self.defaults.synchronize()
            
            // If user creation is successful, sends user to ProfilingViewController
            self.presentAlertWithEmailVerification()
        }
    }
    
    // Sends user to the next ViewController with custom transition
    private func pushExistingUserToViewController() {
        
        // Recurring users might have changed phone, so UserDefaults (LoggedIn & Profiled) need to be updated to true
        UserDefaults.standard.setLoggedIn(value: true)
        
        // Check if user was created
        NetworkManager.shared.isUserCreated(onFail: {
            
            self.pushNewUserToProfilingController()
            
        }) { (dictionary, id) in
            
            self.pushExistingUserToTabController()
        }
    }
    
    private func pushExistingUserToTabController() {
        
        UserDefaults.standard.setProfiled(value: true)
        
        let controller = TabBarController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
        
    }
    
    private func pushNewUserToProfilingController() {
        
        UserDefaults.standard.setLoggedIn(value: true)
        UserDefaults.standard.setProfiled(value: false)
        
        let controller = ProfilingController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    private func presentAlertWithEmailVerification() {
        
        let alertVC = UIAlertController(title: "Are you, you?", message: "Yap, we need to confirm you're you, so we've send you an email to \(String(describing: defaults.value(forKey: "email")!)) 📩 Please make sure you verify your account whenever possible.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Got it", style: .default, handler: { (action) in
            self.pushNewUserToProfilingController()
        }))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func presentAlertWithEmailVerificationError() {
        
        let alertVC = UIAlertController(title: "We still don't know if you're you!", message: "We sent you another verification email to \(String(describing: defaults.value(forKey: "email")!)). Please verify your account within 1 bussiness day, otherwise your account will be put on hold 🚫", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Upss, doing it now! 😅", style: .default, handler: { (action) in
            self.pushExistingUserToViewController()
        }))
        
        present(alertVC, animated: true, completion: nil)
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

// MARK: UITextViewDelegate

extension SignUpController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
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
            let alertController = UIAlertController(title: "No internet connection 😳", message: "We'll keep trying to reconnect. Meanwhile, could you please check your Wifi or Cellular data?", preferredStyle: .alert)
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
