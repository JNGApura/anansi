//
//  FeedbackPagesViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class FeedbackPagesViewController: UIPageViewController {

    // Custom initializers
    fileprivate lazy var feedbackPages: [FeedbackPage] = {
        return [
            FeedbackPage(title: "What do you think of our app?",
                         description: "We'd love to know how your experience has been so far. Tell us anything, no hard feelings!",
                         buttonLabelFirst: "Lovin' it!",
                         buttonLabelSecond: "Uh, take me back"),
            FeedbackPage(title: "Glad to hear it! 😍",
                         description: "Could you rate us? It helps us do more of what you love, and we would really appreciate it!",
                         buttonLabelFirst: "Rate TEDxULisboa",
                         buttonLabelSecond: "No, thanks"),
            FeedbackPage(title: "We're sorry to hear that! 😔",
                         description: "Could you let us know why you aren't satisfied with the app?",
                         buttonLabelFirst: "Submit feedback",
                         buttonLabelSecond: "No, thanks"),
            FeedbackPage(title: "You got it! 🤗",
                         description: "Your feedback is important to us and will help us improve TEDxULisboa's app. Thank you!",
                         buttonLabelSecond: "Take me back")
        ]
    }()
    
    var user: User?
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "Feedback")
        b.backgroundColor = .background
        b.hidesBottomLine()
        b.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    
    // Initialization (to programatically change transition style to .scroll)
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Adds subviews
        [topbar].forEach { view.addSubview($0) }
        view.backgroundColor = .background
        
        // Sets initial view controller as FeedbackPage [0]
        let identifier = 0
        self.setViewControllers([FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])], direction: .forward, animated: false, completion: nil)
        
        // Adds observers to Notification Center, so the pageViewController knows when to set a new FeedbackPageView
        NotificationCenter.default.addObserver(self, selector: #selector(ratingPage), name: NSNotification.Name(rawValue: "happyFlow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(feedbackPage), name: NSNotification.Name(rawValue: "unhappyFlow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completionPage), name: NSNotification.Name(rawValue: "feedbackSubmitted"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)

        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: Const.barHeight)
        
        NSLayoutConstraint.activate([
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: Const.barHeight + statusBarHeight),
            
        ])
    }
    
    // MARK: User Interaction
    
    @objc func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func ratingPage(_:AnyObject) {
        let identifier = 1
        let p = FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])
        setViewControllers([p], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func feedbackPage(_:AnyObject) {
        let identifier = 2
        let p = FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])
        p.user = user
        setViewControllers([p], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func completionPage(_:AnyObject) {
        let identifier = 3
        let p = FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])
        setViewControllers([p], direction: .forward, animated: true, completion: nil)
    }
}
