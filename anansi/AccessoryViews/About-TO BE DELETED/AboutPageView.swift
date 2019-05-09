//
//  AboutPageView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 21/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class AboutPageView: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .background
        sv.layoutIfNeeded()
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let previousViewElement = UIView()
    
    private var section = [AboutPageSection]()
    
    // AboutPages initializer > gets AboutPageSection from SettingsViewController
    init(id: String) {
        
        // Fetches about data from settings.JSON
        if let data = dataFromFile("settings") {
            if let aboutPages = About(data: data) {
                for item in aboutPages.data {
                    if item.id == id {
                        self.section = item.section!
                    }
                }
            }
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets scrollview for entire view
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        
        // Sets constants
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        // Loops through all AboutPageSection items/objects
        var previousViewElement : UIStackView!
        for item in section {
            
            // Creates itemTitle for sectionStackView
            let itemTitle: UILabel = {
                let title = UILabel()
                title.font = UIFont.boldSystemFont(ofSize: Const.headlineFontSize)
                title.textColor = .primary
                title.text = item.title!
                return title
            }()
            
            // Creates itemText for sectionStackView
            let itemText: UITextView = {
                let text = UITextView()
                text.textContainerInset = UIEdgeInsets(top: 8.0, left: -4.0, bottom: 8.0, right: -4.0) // top, left, bottom, right
                text.translatesAutoresizingMaskIntoConstraints = false
                text.isScrollEnabled = false
                text.isEditable = false
                text.formatHTMLText(htmlText: item.text!, lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0, alignment: .left)
                return text
            }()
            
            // Creates sectionStackView from title + text views
            let sectionStackView = UIStackView(arrangedSubviews: [itemTitle, itemText])
            sectionStackView.translatesAutoresizingMaskIntoConstraints = false
            sectionStackView.axis = .vertical
            sectionStackView.distribution = .fill
            scrollView.addSubview(sectionStackView)
            
            // Adds constraints
            NSLayoutConstraint.activate([
                itemTitle.widthAnchor.constraint(equalTo: sectionStackView.widthAnchor, constant: -Const.marginSafeArea * 2),
                itemTitle.topAnchor.constraint(equalTo: sectionStackView.topAnchor, constant: 4.0),
                itemTitle.leadingAnchor.constraint(equalTo: sectionStackView.leadingAnchor, constant: Const.marginSafeArea),
                itemTitle.heightAnchor.constraint(equalToConstant: navigationBarHeight),
                sectionStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                sectionStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            // Sets contraints to sectionStackView to display the next one after the bottomAnchor of the previous one
            previousViewElement == nil ? NSLayoutConstraint.activate([sectionStackView.topAnchor.constraint(equalTo: scrollView.topAnchor)]) : NSLayoutConstraint.activate([sectionStackView.topAnchor.constraint(equalTo: previousViewElement.bottomAnchor, constant: -8.0)])
            previousViewElement = sectionStackView
            
        }
        
        // Updates scrollView's bottomAnchor to set contentSize
        NSLayoutConstraint.activate([previousViewElement.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0)])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            
            // Adds custom leftBarButton
            let backButton = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action:#selector(backAction(_:)))
            navigationItem.leftBarButtonItem = backButton
        }
    }
    
    // MARK: Custom functions
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
