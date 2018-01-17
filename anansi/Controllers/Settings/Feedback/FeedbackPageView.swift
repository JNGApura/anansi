//
//  FeedbackPageView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedbackPageView: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    // Custom initializers
    private let marginDist = 20.0
    
    private let pageIdentifier : Int
    
    private let page : FeedbackPage
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = Color.background
        sv.layoutIfNeeded()
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let pageTitle: UILabel = {
        let title = UILabel()
        title.textColor = Color.primary
        title.numberOfLines = 0
        title.lineBreakMode = NSLineBreakMode.byWordWrapping
        title.font = UIFont.boldSystemFont(ofSize: 24.0)
        return title
    }()
    
    private let pageDescription: UILabel = {
        let description = UILabel()
        description.numberOfLines = 0
        description.lineBreakMode = NSLineBreakMode.byWordWrapping
        description.font = UIFont.systemFont(ofSize: 17.0)
        return description
    }()
    
    private lazy var feedbackTextBox: UITextView = {
        let textBox = UITextView()
        textBox.font = UIFont.systemFont(ofSize: 16.0)
        textBox.backgroundColor = Color.tertiary.withAlphaComponent(0.4)
        textBox.textColor = Color.secondary.withAlphaComponent(0.8)
        textBox.isEditable = true
        textBox.isScrollEnabled = true
        textBox.autocorrectionType = .no
        textBox.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8) // top, left, bottom, right
        return textBox
    }()
    private lazy var feedbackTextLabel = "Please share any relevant steps to reproduce the problem you had."
    
    private let sectionStackView : UIStackView = {
        let ssv = UIStackView()
        ssv.translatesAutoresizingMaskIntoConstraints = false
        ssv.axis = .vertical
        ssv.alignment = .fill
        return ssv
    }()
    
    private lazy var iconHappy : UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "happy-green"))
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(happyIconTapped)))
        return image
    }()
    
    private lazy var iconUnhappy : UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "unhappy-red"))
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unhappyIconTapped)))
        return image
    }()
    
    private let iconStackView : UIStackView = {
        let ssv = UIStackView()
        ssv.translatesAutoresizingMaskIntoConstraints = false
        ssv.distribution = .fillEqually
        ssv.spacing = -80.0
        return ssv
    }()
    
    private let firstButton = PrimaryButton()
    
    private var secondButton = TertiaryButton()
    
    private let buttonStackView : UIStackView = {
        let ssv = UIStackView()
        ssv.translatesAutoresizingMaskIntoConstraints = false
        ssv.axis = .vertical
        ssv.distribution = .fillEqually
        ssv.spacing = 4.0
        return ssv
    }()
    
    // Class initializer
    
    init(identifier: Int, page: FeedbackPage) {
        
        self.pageIdentifier = identifier
        self.page = page
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title text
        pageTitle.text = page.title
        pageTitle.formatTextWithLineSpacing(lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0.5, alignment: .left)
        sectionStackView.addArrangedSubview(pageTitle)
        
        // Set description text
        pageDescription.text = page.description
        pageDescription.formatTextWithLineSpacing(lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0.5, alignment: .left)
        sectionStackView.addArrangedSubview(pageDescription)
        sectionStackView.setCustomSpacing(20.0, after: pageTitle)
        
        // Set feedback textbox
        if pageIdentifier == 2 {
            feedbackTextBox.delegate = self
            feedbackTextBox.text = feedbackTextLabel
            feedbackTextBox.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1.15, hyphenation: 0.5, alignment: .left)
            sectionStackView.addArrangedSubview(feedbackTextBox)
            sectionStackView.setCustomSpacing(20.0, after: pageDescription)
        }
        
        // Sets scrollview for entire view
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        
        // Add sectionStackView to scrollView
        scrollView.addSubview(sectionStackView)
        
        if pageIdentifier == 0 {
            
            // Add imageStackView to view
            iconStackView.addArrangedSubview(iconUnhappy)
            iconStackView.addArrangedSubview(iconHappy)
            view.addSubview(iconStackView)
            
        } else {
            
            // Sets firstButton (Primary)
            firstButton.setTitle(page.buttonLabelFirst, for: .normal)
            buttonStackView.addArrangedSubview(firstButton)
            
            // Sets secondButton (Tertiary)
            secondButton.setTitle(page.buttonLabelSecond, for: .normal)
            buttonStackView.addArrangedSubview(secondButton)
            
            // Adds buttonStackView to scrollView
            scrollView.addSubview(buttonStackView)
            
            if pageIdentifier == 1 {
                
                // Adds targets to firstButton
                firstButton.addTarget(self, action: #selector(rateApp), for: .touchUpInside)

            } else if pageIdentifier == 2 {
                
                // Disables "send feedback" button
                firstButton.alpha = 0.4
                firstButton.isEnabled = false
                
                // Adds targets to firstButton
                firstButton.addTarget(self, action: #selector(submitFeedback), for: .touchUpInside)
                
            } else if pageIdentifier == 3 {
                
                // Hides firstButton, because we don't have primary action
                firstButton.isHidden = true
                
                // Changes secondButton UI to seem like a secondaryButton
                secondButton.layer.cornerRadius = 24.0
                secondButton.layer.borderWidth = 1.5
                secondButton.layer.borderColor = Color.secondary.cgColor
            }
            
            // Adds target to secondButton
            secondButton.addTarget(self, action: #selector(leaveFlow), for: .touchUpInside)
        }
        
        // Setups layout constraints
        setupLayoutConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Creates keyboard-specific notification observers, so that we can track when the keyboard is presented or is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        // Removes keyboard notification observers
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    private func setupLayoutConstraints() {
     
        // Activates contraints of the elements that belong to all pages (scrollView, pageTitle and sectionStackView)
        NSLayoutConstraint.activate([
            //scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            sectionStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            sectionStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(view.frame.size.height / 4)),
            
            pageTitle.widthAnchor.constraint(equalTo: sectionStackView.widthAnchor, constant: CGFloat(-marginDist*2)),
            pageTitle.topAnchor.constraint(equalTo: sectionStackView.topAnchor),
            pageTitle.leadingAnchor.constraint(equalTo: sectionStackView.leadingAnchor, constant: CGFloat(marginDist)),
        ])

        // Activates contraints the feedbackTextBox, if exists
        if pageIdentifier == 2 {
            NSLayoutConstraint.activate([feedbackTextBox.heightAnchor.constraint(equalToConstant: CGFloat(marginDist*9 - 4.0))])
        }
        
        // Activates contraints imageStackView
        if pageIdentifier == 0 {
            
            NSLayoutConstraint.activate([
                iconStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat(-marginDist*3)),
                iconStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                iconStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
        
        // Activates contraints buttonStackView
        } else {
        
            var buttonAreaHeight = marginDist*5
            var distanceFromBottom = 0.0
            
            // Changes buttonAreaHeight and distanceFromBottom because we now have only ONE button
            if pageIdentifier == 3 {
                buttonAreaHeight = marginDist*2.5 - 2.0
                distanceFromBottom = marginDist*1.25
            }
            
            NSLayoutConstraint.activate([
                buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat(-distanceFromBottom)),
                buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginDist*4)),
                buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginDist*4)),
                buttonStackView.heightAnchor.constraint(equalToConstant: CGFloat(buttonAreaHeight))
            ])
        }
    }
    
    // MARK: Custom functions
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func happyIconTapped(_ sender: UIImageView) {
        
        // Posts notification to NotificationCenter, so pageViewController knows what page is next
        NotificationCenter.default.post(name: Notification.Name(rawValue: "happyFlow"), object: self)
        
        // TO DO: Storing number of happyIconTaps?
        //print("happy button clicked")
    }
    
    @objc func unhappyIconTapped(_ sender: UIImageView) {
        
        // Posts notification to NotificationCenter, so pageViewController knows what page is next
        NotificationCenter.default.post(name: Notification.Name(rawValue: "unhappyFlow"), object: self)
        
        // TO DO: Storing number of unhappyIconTaps?
        //print("unhappy button clicked")
    }
    
    @objc func leaveFlow(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func rateApp(){
        
        let appId = "id1209945212"
        
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        // TO DO: add # taps in the back-end
        
        let when = DispatchTime.now() + 0.4 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func submitFeedback(_ sender: UIButton){
        
        // Sends feedback to back-end
        let feedbackMessage = feedbackTextBox.text!
        let post : [String : Any] = ["message": feedbackMessage]
        
        let databaseReference = Database.database().reference()
        databaseReference.child("FeedbackPosts").childByAutoId().setValue(post)
        
        // TO DO: send feedback when authenticated to user's db
        
        //print(sender.params["text"] ?? "Nothing was sent.")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "feedbackSubmitted"), object: self)
    }
    
    // MARK: Keyboard-specific functions
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if feedbackTextBox.isFirstResponder {
                self.view.frame.origin.y = feedbackTextBox.frame.maxY - keyboardSize.origin.y
            }
        }
    }

    // MARK: TextViewDelegate functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == feedbackTextLabel) {
            textView.text = ""
            textView.textColor = Color.secondary
        }
        firstButton.isEnabled = true
        firstButton.alpha = 1
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.text == "") {
            textView.text = feedbackTextLabel
            textView.textColor = Color.secondary.withAlphaComponent(0.8)
            firstButton.isEnabled = false
            firstButton.alpha = 0.4
        }
        textView.resignFirstResponder()
    }
}
