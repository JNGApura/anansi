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
                         description: "We'd love to know how's been your experience, so far. You can tell us anything, no hard feelings!",
                         buttonLabelFirst: "Lovin' it!",
                         buttonLabelSecond: "Uh, take me back"),
            FeedbackPage(title: "Glad to hear it!",
                         description: "Could you rate us? It helps us do more of what you love, and we would really appreciate it.",
                         buttonLabelFirst: "Rate TEDxISTAlameda",
                         buttonLabelSecond: "No, thanks"),
            FeedbackPage(title: "We're sorry to hear that!",
                         description: "Could you let us know why you aren't satisfied with the app?",
                         buttonLabelFirst: "Submit feedback",
                         buttonLabelSecond: "No, thanks"),
            FeedbackPage(title: "You got it!",
                         description: "Thank you for letting us know! Your feedback is important to us, and it will help us improve this app for you. In the meanwhile, continue to spread ideas!",
                         buttonLabelSecond: "Take me back")
        ]
    }()
    
    // Initialization (to programatically change transition style to .scroll)
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets initial view controller as FeedbackPage [0]
        let identifier = 0
        self.setViewControllers([FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])], direction: .forward, animated: false, completion: nil)
        
        // Adds observers to Notification Center, so the pageViewController knows when to set a new FeedbackPageView
        NotificationCenter.default.addObserver(self, selector: #selector(ratingPage), name: NSNotification.Name(rawValue: "happyFlow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(feedbackPage), name: NSNotification.Name(rawValue: "unhappyFlow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completionPage), name: NSNotification.Name(rawValue: "feedbackSubmitted"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        let navigationBar = navigationController?.navigationBar
        navigationBar!.barTintColor = Color.background
        navigationBar!.isTranslucent = false
        
        // Adds custom leftBarButton
        let backButton = UIBarButtonItem(image: UIImage(named:"back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action:#selector(backAction(_:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: User Interaction
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func ratingPage(_:AnyObject) {
        let identifier = 1
        let p = FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])
        self.setViewControllers([p], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func feedbackPage(_:AnyObject) {
        let identifier = 2
        let p = FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])
        self.setViewControllers([p], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func completionPage(_:AnyObject) {
        let identifier = 3
        let p = FeedbackPageView(identifier: identifier, page: feedbackPages[identifier])
        self.setViewControllers([p], direction: .forward, animated: true, completion: nil)
    }
}
