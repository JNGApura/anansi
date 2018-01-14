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
    /*fileprivate lazy var pages: [UIViewController] = {
        return [
            FeedbackSentConfirmationViewController(),
            UnhappyFeedbackViewController(),
            FeedbackPage(),
            HappyFeedbackViewController()
        ]
    }()*/
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets initial view controller as (...)
        // identifier = 1 > feedback question
        self.setViewControllers([FeedbackPages(identifier: 1)], direction: .forward, animated: false, completion: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(goNextPage), name: NSNotification.Name(rawValue: "happyButton"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(goPrevPage), name: NSNotification.Name(rawValue: "unhappyButton"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(goPrevPrevPage), name: NSNotification.Name(rawValue: "feedbackConfirmed"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        let navigationBar = navigationController?.navigationBar
        navigationBar!.barTintColor = Color.background
        navigationBar!.isTranslucent = false
        
    }
    
    // MARK: User Interaction
    
    /*@objc func goNextPage(_:AnyObject) {
        self.setViewControllers([pages[3]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func goPrevPage(_:AnyObject) {
        self.setViewControllers([pages[1]], direction: .reverse, animated: true, completion: nil)
    }
    
    @objc func goPrevPrevPage(_:AnyObject) {
        self.setViewControllers([pages[0]], direction: .reverse, animated: true, completion: nil)
    }*/
    
}
