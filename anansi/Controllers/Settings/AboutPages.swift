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
    var scrollView: UIScrollView!
    var section = [AboutPageSection]()
    
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
        
        // Sets contstants
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets scrollview for entire view
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        scrollView.backgroundColor = .white
        scrollView.layoutIfNeeded()
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // Loops through all AboutPageSection items/objects
        var yPos : CGFloat = 0.0
        for item in section {
            
            // Creates sectionView for each section
            let sectionItem = UIView(frame: CGRect(x: 0.0, y: yPos, width: screenWidth, height: screenHeight - navigationBarHeight))
            scrollView.addSubview(sectionItem)
            
            // Creates itemTitle and itemText inside each sectionItem
            let itemTitle = UILabel(frame: CGRect(x: 16.0, y: 4.0, width: screenWidth , height: navigationBarHeight))
            itemTitle.text = item.title!
            itemTitle.font = UIFont.boldSystemFont(ofSize: 22)
            itemTitle.textColor = Color.secondary
            sectionItem.addSubview(itemTitle)
            
            let itemText = UITextView(frame: CGRect(x: 0.0, y: itemTitle.frame.size.height, width: screenWidth , height: 0.0))
            itemText.formatHTMLText(htmlText: item.text!, lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0, alignment: .left)
            itemText.textContainerInset = UIEdgeInsetsMake(8.0, 11.0, 8.0, 11.0) // top, left, bottom, right
            itemText.translatesAutoresizingMaskIntoConstraints = true
            itemText.sizeToFit()
            itemText.isScrollEnabled = false
            itemText.isEditable = false
            sectionItem.addSubview(itemText)
            
            // Updates yPos with section maxY
            yPos += itemText.frame.maxY - 16.0
        }
        
        // Updates scrollView contentSize
        scrollView.contentSize = CGSize(width: screenWidth, height: yPos + statusBarHeight + navigationBarHeight)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    func setupNavigationBarItems() {
        
        let navigationBar = navigationController?.navigationBar
        navigationBar!.barTintColor = Color.background
        navigationBar!.isTranslucent = false
        
    }
    
    // MARK: Custom functions
}
