//
//  FeedbackPageView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class FeedbackPageView: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    // Custom initializers    
    private let pageIdentifier : Int
    
    private let page : FeedbackPage
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .background
        sv.layoutIfNeeded()
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let pageTitle: UILabel = {
        let title = UILabel()
        title.textColor = .primary
        title.numberOfLines = 0
        title.lineBreakMode = NSLineBreakMode.byWordWrapping
        title.font = UIFont.boldSystemFont(ofSize: Const.titleFontSize)
        return title
    }()
    
    private let pageDescription: UILabel = {
        let description = UILabel()
        description.numberOfLines = 0
        description.lineBreakMode = NSLineBreakMode.byWordWrapping
        description.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        return description
    }()
    
    private lazy var feedbackTextBox: UITextView = {
        let textBox = UITextView()
        textBox.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        textBox.backgroundColor = UIColor.tertiary.withAlphaComponent(0.4)
        textBox.textColor = UIColor.secondary.withAlphaComponent(0.8)
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
        ssv.spacing = -Const.marginAnchorsToContent*4
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
    
    //override var canBecomeFirstResponder: Bool { return true }
    
    /*lazy var keyboardAccessoryView: KeyboardAccessoryView = {
        let kv = KeyboardAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50.0))
        kv.textview = feedbackTextBox
        return kv
    }()
    
    override var inputAccessoryView: UIView {
        return keyboardAccessoryView
    }*/
    
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
        sectionStackView.setCustomSpacing(Const.marginAnchorsToContent, after: pageTitle)
        
        // Set feedback textbox
        if pageIdentifier == 2 {
            feedbackTextBox.delegate = self
            feedbackTextBox.text = feedbackTextLabel
            feedbackTextBox.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1.15, hyphenation: 0.5, alignment: .left)
            sectionStackView.addArrangedSubview(feedbackTextBox)
            sectionStackView.setCustomSpacing(Const.marginAnchorsToContent, after: pageDescription)
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
                secondButton.layer.borderColor = UIColor.secondary.cgColor
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
        
        // Removes keyboard notification observers
        NotificationCenter.default.removeObserver(self)
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
            
            pageTitle.widthAnchor.constraint(equalTo: sectionStackView.widthAnchor, constant: -Const.marginAnchorsToContent * 2),
            pageTitle.topAnchor.constraint(equalTo: sectionStackView.topAnchor),
            pageTitle.leadingAnchor.constraint(equalTo: sectionStackView.leadingAnchor, constant: Const.marginAnchorsToContent),
        ])

        // Activates contraints the feedbackTextBox, if exists
        if pageIdentifier == 2 {
            NSLayoutConstraint.activate([
                feedbackTextBox.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.215)
            ])//Const.marginAnchorsToContent * 9 - 4.0)])
        }
        
        // Activates contraints imageStackView
        if pageIdentifier == 0 {
            
            NSLayoutConstraint.activate([
                iconStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginAnchorsToContent * 3),
                iconStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                iconStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
        
        // Activates contraints buttonStackView
        } else {
        
            var buttonAreaHeight = Const.marginAnchorsToContent * 5
            var distanceFromBottom : CGFloat = 0.0
            
            // Changes buttonAreaHeight and distanceFromBottom because we now have only ONE button
            if pageIdentifier == 3 {
                buttonAreaHeight = Const.marginAnchorsToContent * 2.5 - 2.0
                distanceFromBottom = Const.marginAnchorsToContent * 1.25
            }
            
            NSLayoutConstraint.activate([
                buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -distanceFromBottom),
                buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.675),
                buttonStackView.heightAnchor.constraint(equalToConstant: buttonAreaHeight)
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
        
        // Storing number of happyIconTaps
        NetworkManager.shared.updatesFeedbackValue(name: "happy")
    }
    
    @objc func unhappyIconTapped(_ sender: UIImageView) {
        
        // Posts notification to NotificationCenter, so pageViewController knows what page is next
        NotificationCenter.default.post(name: Notification.Name(rawValue: "unhappyFlow"), object: self)
        
        // Storing number of unhappyIconTaps
        NetworkManager.shared.updatesFeedbackValue(name: "unhappy")
    }
    
    @objc func leaveFlow(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rateApp(){
        
        let appId = "id376183339"
        
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        // Add # taps in the back-end
        NetworkManager.shared.updatesFeedbackValue(name: "rated")
        
        let when = DispatchTime.now() + 0.4 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func submitFeedback(_ sender: UIButton){
        
        // Sends feedback to back-end
        let message : [String : Any] = ["message": feedbackTextBox.text!]
        NetworkManager.shared.setFeedbackValue(name: "posts", post: message)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "feedbackSubmitted"), object: self)
    }
    
    // MARK: Keyboard-specific functions
    
    @objc func keyboardWillHide() {
        view.transform = CGAffineTransform.identity
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            let textBoxRelativeMaxY = feedbackTextBox.frame.maxY + feedbackTextBox.frame.height
            let screenHeight = view.frame.height
            
            let offsetY = (screenHeight - textBoxRelativeMaxY - 16)
            
            if offsetY < keyboardHeight {
                view.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - offsetY))
                view.layoutIfNeeded()
            }
        }
    }

    // MARK: TextViewDelegate functions
    
    /*func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupTextFieldsAccessoryView()
        return true
    }*/
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == feedbackTextLabel) {
            textView.text = ""
            textView.textColor = .secondary
        }
        firstButton.isEnabled = true
        firstButton.alpha = 1
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.text == "") {
            textView.text = feedbackTextLabel
            textView.textColor = UIColor.secondary.withAlphaComponent(0.8)
            firstButton.isEnabled = false
            firstButton.alpha = 0.4
        }
        textView.resignFirstResponder()
    }
    
    func setupTextFieldsAccessoryView() {
        
        guard feedbackTextBox.inputAccessoryView == nil else {
            return
        }
        
        // Create toolBar
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .primary
        toolBar.backgroundColor = .background
        toolBar.sizeToFit()
        
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(didPressDoneButton))
        toolBar.items = [flexibleSpace, doneButton]
        
        // Assing toolbar as inputAccessoryView
        feedbackTextBox.inputAccessoryView = toolBar
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        feedbackTextBox.resignFirstResponder()
    }
}
