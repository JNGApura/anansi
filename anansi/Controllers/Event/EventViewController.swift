//
//  EventViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class EventViewController: UIViewController,
    UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    // Custom initializers
    
    let customPhrases = ["Stay tuned.",
                         "I said: \"Stay tuned.\"",
                         "Please, stop tapping me.",
                         "I'm serious.",
                         "Well, that's all I can say.",
                         "I could actually tell you one thing.",
                         "Wait for it.",
                         "Yap, you got it:"]
    var currentPhrase = 0
    
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondary
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "Event"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Event")
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    let insideView : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let textLabel : UIButton = {
        let tl = UIButton()
        tl.setTitle("Stay tuned.", for: .normal)
        tl.setTitleColor(.secondary, for: .normal)
        tl.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        tl.titleLabel?.textAlignment = .center
        tl.backgroundColor = .background
        tl.addTarget(self, action: #selector(handlePhrases), for: .touchUpInside)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets up UI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(insideView)
        insideView.addSubview(textLabel)
        
        // Sets layout constraints
        setupLayoutConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            navigationItem.titleView = titleLabelView
        }
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            
            // Activates scrollView constraints
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activates contentView constraints
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 58.0),
            
            // Activates insideView constraints
            insideView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            insideView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            insideView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            insideView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -58.0),
            insideView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: insideView.centerXAnchor),
            textLabel.widthAnchor.constraint(equalTo: insideView.widthAnchor),
            textLabel.centerYAnchor.constraint(equalTo: insideView.centerYAnchor),
        ])
        
    }
    
    // MARK: Custom functions
    
    @objc func handlePhrases() {
        
        currentPhrase += 1
        if currentPhrase > customPhrases.count - 1 {
            currentPhrase = 0
        }
        textLabel.setTitle(customPhrases[currentPhrase], for: .normal)
    }
    
    // MARK: ScrollViewDidScroll function
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = scrollView.contentOffset.y
        let titleOriginY : CGFloat = headerView.headerTitle.frame.origin.y
        let lineMaxY : CGFloat = headerView.headerBottomBorder.frame.maxY
        let label = navigationItem.titleView as! UILabel
        
        if offsetY >= titleOriginY {
            if (offsetY - lineMaxY) < 0 {
                label.alpha = (offsetY - titleOriginY) / (lineMaxY - titleOriginY)
            } else {
                label.alpha = 1.0
            }
        } else {
            label.alpha = 0.0
        }
    }
}
