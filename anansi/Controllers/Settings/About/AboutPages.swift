//
//  AboutPages.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class AboutPages: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = Color.background
        sv.layoutIfNeeded()
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let previousViewElement = UIView()
    
    private var section = [AboutPageSection]()
    
    // AboutPages initializer > gets AboutPageSection from SettingsViewController
    
    init(section: [AboutPageSection]) {
        self.section = section
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
                title.font = UIFont.boldSystemFont(ofSize: 22)
                title.textColor = Color.primary
                title.text = item.title!
                return title
            }()
            
            // Creates itemText for sectionStackView
            let itemText: UITextView = {
                let text = UITextView()
                text.textContainerInset = UIEdgeInsetsMake(8.0, -4.0, 8.0, -4.0) // top, left, bottom, right
                text.translatesAutoresizingMaskIntoConstraints = false
                text.isScrollEnabled = false
                text.isEditable = false
                text.formatHTMLText(htmlText: item.text!, lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0, alignment: .left)
                return text
            }()

            let contentSize = itemText.sizeThatFits(itemText.bounds.size)
            var frame = itemText.frame
            frame.size.height = contentSize.height
            itemText.frame = frame
            
            // Creates sectionStackView from title + text views
            let sectionStackView = UIStackView(arrangedSubviews: [itemTitle, itemText])
            sectionStackView.translatesAutoresizingMaskIntoConstraints = false
            sectionStackView.axis = .vertical
            sectionStackView.alignment = .fill
            scrollView.addSubview(sectionStackView)
            
            // Adds constraints to itemTitle and sectionStackView
            NSLayoutConstraint.activate([
                itemTitle.widthAnchor.constraint(equalTo: sectionStackView.widthAnchor, constant: -40.0),
                itemTitle.topAnchor.constraint(equalTo: sectionStackView.topAnchor, constant: 4.0),
                itemTitle.leadingAnchor.constraint(equalTo: sectionStackView.leadingAnchor, constant: 20.0),
                itemTitle.heightAnchor.constraint(equalToConstant: navigationBarHeight),
                sectionStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                sectionStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
                ])
            
            // Sets contraints to previous sectionStackView to display the next one after the bottomAnchor of the previous one
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
        
        let navigationBar = navigationController?.navigationBar
        navigationBar!.barTintColor = Color.background
        navigationBar!.isTranslucent = false
        
    }
    
    // MARK: Custom functions
}
