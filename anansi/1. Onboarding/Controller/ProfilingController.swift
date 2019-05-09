//
//  ProfilingController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfilingController: UIViewController, UIScrollViewDelegate, UIPageViewControllerDelegate {
    
    // Custom initializers
    let defaults = UserDefaults.standard
    
    private let profilingPages = [
        ProfilingPage(title: "Thanks for signing in!",
                      description: "To connect with other attendees, you need to provide your real name:",
                      questionTitle: "What's your name?",
                      questionPlaceholder: "First and last name"),
        ProfilingPage(title: "Let others get to know you!",
                      description: "Tell other attendees what you do, whether you are a student or a professional.",
                      questionTitle: "What do you do?",
                      questionPlaceholder: "E.g. dream catcher"),
        ProfilingPage(title: "Last step!",
                      description: "Let others know where you are from, or where you work from. This will break the ice!",
                      questionTitle: "Where are you from?",
                      questionPlaceholder: "E.g. Atlantis"),
    ]
    
    private var currentPage = 0
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let labelPlaceholder: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.textColor = UIColor.secondary.withAlphaComponent(0.4)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let nextButton : TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("Next ", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.setImage(UIImage(named: "next")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.imageView?.tintColor = .secondary
        b.alpha = 0.4
        b.isEnabled = false
        b.semanticContentAttribute = .forceRightToLeft
        b.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private lazy var pageControl: PageControlWithBars = {
        let pc = PageControlWithBars()
        pc.currentPage = currentPage
        pc.numberOfPages = profilingPages.count
        pc.spacing = 4.0
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    lazy var answerText: UITextView = {
        let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        tf.delegate = self
        return tf
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
        
        view.backgroundColor = .background
        
        // Adds pageController to view as ChilViewController
        addChild(pageController)
        
        // Add other subviews
        bottomControlView.addSubview(nextButton)
        [scrollView, pageControl, bottomControlView].forEach { view.addSubview($0) }
        [pageController.view, answerText, labelPlaceholder].forEach { scrollView.addSubview($0) }

        pageController.didMove(toParent: self)
        
        // Setting up answerTextField to update every time we go to a new page
        answerText.layer.zPosition = 1
        labelPlaceholder.text = profilingPages[currentPage].questionPlaceholder
        answerText.text = ""
        
        // Sets up the layout constraints
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageControl.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Const.marginSafeArea),
            pageControl.bottomAnchor.constraint(equalTo: pageController.view.topAnchor, constant: -Const.marginSafeArea),
            pageControl.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            pageController.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            pageController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            pageController.view.heightAnchor.constraint(equalToConstant: 212.0),
            
            answerText.bottomAnchor.constraint(equalTo: pageController.view.bottomAnchor, constant: -2.0),
            answerText.widthAnchor.constraint(equalTo: pageController.view.widthAnchor, constant: -8.0),
            answerText.centerXAnchor.constraint(equalTo: pageController.view.centerXAnchor),
            answerText.heightAnchor.constraint(equalToConstant: 26.0),
            
            labelPlaceholder.centerXAnchor.constraint(equalTo: answerText.centerXAnchor),
            labelPlaceholder.widthAnchor.constraint(equalTo: answerText.widthAnchor, constant: -10.0),
            labelPlaceholder.topAnchor.constraint(equalTo: answerText.topAnchor),
            labelPlaceholder.heightAnchor.constraint(equalToConstant: 26.0),
            
            bottomControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlView.heightAnchor.constraint(equalToConstant: Const.marginSafeArea * 2.5),
            
            nextButton.centerYAnchor.constraint(equalTo: bottomControlView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: bottomControlView.trailingAnchor, constant: -Const.marginSafeArea),
            nextButton.heightAnchor.constraint(equalTo: bottomControlView.heightAnchor),
            
        ])
        
        bottomControlBottomAnchor = bottomControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomControlBottomAnchor?.isActive = true
        
        // Creates keyboard-specific notification observers, so that we can track when the keyboard is presented or is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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

        // Stores answers from profiling questions
        storeProfilingAnswer(currentPage)
        
        // Next button is disabled to avoid double-tapping
        nextButton.isEnabled = false
        self.nextButton.alpha = 0.4
        
        // cellControl is updated with newPage value
        let nextPage = currentPage + 1
        pageControl.setCumulativePageIndicator(nextPage)
        
        // If currentPage is the last, then "Next" becomes "Done"
        if nextPage == profilingPages.count - 1 {
            
            nextButton.setTitle("Done ", for: .normal)
            nextButton.setImage(UIImage(named: "check")?.withRenderingMode(.alwaysTemplate), for: .normal)
            nextButton.imageView?.tintColor = .primary
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
                self.answerText.text = ""
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
    
    // Stores answers in UserDefaults
    func storeProfilingAnswer(_ currentPage: Int) {

        let answer = answerText.text
        
        switch currentPage {
        case 0:
            defaults.set(answer, forKey: "name")
            
        case 1:
            defaults.set(answer, forKey: "occupation")
            
        case 2:
            defaults.set(answer, forKey: "location")
            
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
        
        // Now we're done with the onboarding & profiling, let's create the user!
        createUser()
    }
    
    func createUser() {
        
        let email = defaults.value(forKey: "email") as! String
        let ticket = defaults.value(forKey: "ticket") as! String
        let name = defaults.value(forKey: "name") as! String
        let occupation = defaults.value(forKey: "occupation") as! String
        let location = defaults.value(forKey: "location") as! String
        
        NetworkManager.shared.createUserInDB(email: email, ticket: ticket, name: name, occupation: occupation, location: location) {
            
            // Sends user to TabBarController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                let controller = TabBarController()
                controller.modalPresentationStyle = .overFullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    // MARK : KEYBOARD-related functions
    
    @objc func keyboardWillHide() {
        
        bottomControlBottomAnchor?.constant = 0
        scrollView.transform = CGAffineTransform.identity
        view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
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
}
    
// MARK : UITextViewDelegate functions

extension ProfilingController: UITextViewDelegate {
    
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
