//
//  ProfilingController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfilingController: UIViewController, UIScrollViewDelegate, UIPageViewControllerDelegate, UITextViewDelegate {
    
    // Custom initializers
    private let profilingPages = [
        ProfilingPage(description: "Thanks for signing up! To connect with other attendees, you need to provide your real name:", questionTitle: "What's your name?", questionPlaceholder: "First and last names"),
        ProfilingPage(description: "Let other attendees know what is your occupation, whether you are a student or professional.", questionTitle: "What do you do?", questionPlaceholder: "E.g. teacher"),
        ProfilingPage(description: "Last step! Let others know where you are from, or where you work. This will break the ice!", questionTitle: "Where are you from?", questionPlaceholder: "E.g. Lisbon"),
    ]
    
    private var currentPage = 0
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let logo: UIImageView = {
        let i = UIImageView(image: #imageLiteral(resourceName: "TEDxISTAlameda-black"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    private let nextButton : TertiaryButton = {
        let button = TertiaryButton()
        button.setTitle("Next", for: .normal)
        button.tintColor = .secondary
        button.alpha = 0.4
        button.isEnabled = false
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cellControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = currentPage
        pc.numberOfPages = profilingPages.count
        pc.currentPageIndicatorTintColor = .primary
        pc.pageIndicatorTintColor = UIColor.primary.withAlphaComponent(0.2)
        pc.isUserInteractionEnabled = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    lazy var answerText: UITextView = {
        let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2, left: -6, bottom: -2, right: 0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        tf.delegate = self
        return tf
    }()
    
    let labelPlaceholder: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.textColor = UIColor.secondary.withAlphaComponent(0.4)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let bottomControlView: UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var bottomControlBottomAnchor: NSLayoutConstraint?
    
    private lazy var pageController : UIPageViewController = {
        let pc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pc.setViewControllers([ProfilingPageView(page: profilingPages[currentPage])], direction: .forward, animated: false, completion: nil)
        pc.view.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adds pageController to view as ChilViewController
        addChildViewController(pageController)
        
        // Add other subviews
        [scrollView, bottomControlView].forEach { view.addSubview($0) }
        [logo, pageController.view, answerText, labelPlaceholder].forEach { scrollView.addSubview($0) }
        [cellControl, nextButton].forEach { bottomControlView.addSubview($0) }
        pageController.didMove(toParentViewController: self)
        
        // Setting up answerTextField to update every time we go to a new page
        answerText.layer.zPosition = 1
        labelPlaceholder.text = profilingPages[currentPage].questionPlaceholder
        answerText.text = ""
        
        // Sets up the layout constraints
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Const.marginAnchorsToContent * 3),
            logo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Const.marginAnchorsToContent),

            pageController.view.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: Const.marginAnchorsToContent * 4),
            pageController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            pageController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            pageController.view.heightAnchor.constraint(equalToConstant: 212.0),
            
            answerText.bottomAnchor.constraint(equalTo: pageController.view.bottomAnchor, constant: -2.0),
            answerText.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Const.marginAnchorsToContent),
            answerText.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Const.marginAnchorsToContent),
            answerText.heightAnchor.constraint(equalToConstant: 26.0),
            
            labelPlaceholder.centerXAnchor.constraint(equalTo: answerText.centerXAnchor),
            labelPlaceholder.widthAnchor.constraint(equalTo: answerText.widthAnchor),
            labelPlaceholder.topAnchor.constraint(equalTo: answerText.topAnchor),
            labelPlaceholder.heightAnchor.constraint(equalToConstant: 26.0),
            
            bottomControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlView.heightAnchor.constraint(equalToConstant: Const.marginAnchorsToContent * 2.5),
            
            nextButton.centerYAnchor.constraint(equalTo: bottomControlView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: bottomControlView.trailingAnchor, constant: -Const.marginAnchorsToContent),
            nextButton.heightAnchor.constraint(equalTo: bottomControlView.heightAnchor),
            
            cellControl.centerYAnchor.constraint(equalTo: bottomControlView.centerYAnchor),
            cellControl.centerXAnchor.constraint(equalTo: bottomControlView.centerXAnchor),
        ])
        
        bottomControlBottomAnchor = bottomControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomControlBottomAnchor?.isActive = true
        
        // Creates keyboard-specific notification observers, so that we can track when the keyboard is presented or is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleFirstReponser), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom functions
    
    // Presents keyboard for answerTextField
    @objc func handleFirstReponser() {
        answerText.becomeFirstResponder()
    }
    
    // Handles next page
    @objc private func handleNext() {
        
        // Creates a circle of the same size as UIPageControl, to track progress
        createsFilledCircle(currentPage)

        // Stores answers from profiling questions
        storeProfilingAnswer(currentPage)
        
        // Next button is disabled to avoid double-tapping
        nextButton.isEnabled = false
        self.nextButton.alpha = 0.4
        
        // cellControl is updated with newPage value
        let nextPage = currentPage + 1
        cellControl.currentPage = nextPage
        
        // If cellControl's currentPage is the last, then "Next" becomes "Done"
        if nextPage == profilingPages.count - 1 {
            
            nextButton.setTitle("Done ", for: .normal)
            nextButton.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            nextButton.tintColor = .primary
            nextButton.setTitleColor(.primary, for: .normal)
            nextButton.addTarget(self, action: #selector(pushTabBarController), for: .touchUpInside)
        }
        
        // If we still have profilingPages to present, then we fade-out answerTextField to be updated and we update the viewController in pageController
        if nextPage < profilingPages.count {
            
            // Fades out answerTextField
            UIView.animate(withDuration: 0.3, animations: {
                
                self.answerText.alpha = 0.0
            }, completion: { (true) in
                
                // Updates answerTextField with new values (while faded out)
                self.answerText.text = "" //self.profilingPages[nextPage].questionPlaceholder
                self.labelPlaceholder.text = self.profilingPages[nextPage].questionPlaceholder
            })
            
            // Presents next view controller
            pageController.setViewControllers([ProfilingPageView(page: profilingPages[nextPage])], direction: .forward, animated: true, completion: nil)
            
            // Fades in answerTextField
            UIView.animate(withDuration: 0.3, animations: {
                
                self.answerText.alpha = 1.0
            }, completion: { (true) in
                
                self.labelPlaceholder.isHidden = false
            })
            
            currentPage = nextPage
        }
    }
    
    // Function to create circular views of the same size as UIPageControl
    func createsFilledCircle(_ currentPage: Int) {
        
        let margin = CGFloat(currentPage) * (7.0 + 9.0)
        
        let circle: UIView = {
            let v = UIView()
            v.backgroundColor = .primary
            v.layer.cornerRadius = 3.5
            v.layer.masksToBounds = true
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        
        bottomControlView.addSubview(circle)
        
        NSLayoutConstraint.activate([
            circle.leadingAnchor.constraint(equalTo: cellControl.leadingAnchor, constant: margin),
            circle.centerYAnchor.constraint(equalTo: cellControl.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 7.0),
            circle.heightAnchor.constraint(equalToConstant: 7.0),
        ])
    }
    
    // Stores answers in UserDefaults
    func storeProfilingAnswer(_ currentPage: Int) {

        let defaults = UserDefaults.standard
        let answer = answerText.text
        
        switch currentPage {
        case 0:
            // Sets "userName" in UserDefaults
            defaults.set(answer, forKey: "userName")
        case 1:
            // Sets "userOccupation" in UserDefaults
            defaults.set(answer, forKey: "userOccupation")
        case 2:
            // Sets "userLocation" in UserDefaults
            defaults.set(answer, forKey: "userLocation")
        default:
            print("Ups, something went wrong here!")
        }
        defaults.synchronize()
    }
    
    // Sends user to ProfilingController with custom transition
    @objc func pushTabBarController() {
        
        // Hides keyboard
        self.answerText.resignFirstResponder()
        
        // Stores default booleans for the walkthrough / onboarding
        let defaults = UserDefaults.standard
        defaults.setProfiled(value: true)
        
        defaults.setCommunityOnboarded(value: false)
        defaults.setConnectOnboarded(value: false)
        defaults.setEventOnboarded(value: false)
        defaults.setProfileOnboarded(value: false)
        
        // Sends user to TabBarController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            let controller = TabBarController()
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK : KEYBOARD-related functions
    
    @objc func keyboardWillHide() {
        
        bottomControlBottomAnchor?.constant = 0
        scrollView.transform = CGAffineTransform.identity
        view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            if Display.typeIsLike == .iphoneX {
                 bottomControlBottomAnchor?.constant = -keyboardHeight + 28
            } else {
                bottomControlBottomAnchor?.constant = -keyboardHeight
                view.layoutIfNeeded()
            }
            
            let answerTextRelativeMaxY = answerText.frame.maxY
            let bottomControlHeight = bottomControlView.frame.height
            let screenHeight = view.frame.height
            
            let offsetY = (screenHeight - answerTextRelativeMaxY - bottomControlHeight - 12)
            
            if offsetY < keyboardHeight {
                
                scrollView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - offsetY))
                view.layoutIfNeeded()
            }
        }
    }
    
    // MARK : UITextViewDelegate functions
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textLength = prospectiveText.count
        
        // Presents placeholder when length == 0
        if textLength > 0 {
            labelPlaceholder.isHidden = true
        } else {
            labelPlaceholder.isHidden = false
        }
        
        // Enables button when length > 2
        if textLength > 2 {
        
            nextButton.isEnabled = true
            nextButton.alpha = 1
        } else {
            
            nextButton.isEnabled = false
            nextButton.alpha = 0.4
        }
        
        return true
    }
}
