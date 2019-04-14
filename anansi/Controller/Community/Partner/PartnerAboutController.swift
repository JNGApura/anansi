//
//  PartnerAboutController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class PartnerAboutController: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .background
        sv.delegate = self
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondary
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "placeholder"
        return label
    }()
    
    // Creates itemTitle for sectionStackView
    private let itemTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: Const.headlineFontSize)
        title.textColor = .primary
        title.text = "About:"
        return title
    }()
    
    // Creates itemText for sectionStackView
    private let itemText: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    var about = String() {
        didSet {
            itemText.text = about
            itemText.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0, alignment: .left)
            view.layoutIfNeeded()
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets scrollview for entire view
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLayoutSubviews() {
        
        // Creates sectionStackView from title + text views
        let sectionStackView = UIStackView(arrangedSubviews: [itemTitle, itemText])
        sectionStackView.translatesAutoresizingMaskIntoConstraints = false
        sectionStackView.axis = .vertical
        sectionStackView.distribution = .fill
        scrollView.addSubview(sectionStackView)
        
        // Adds constraints
        NSLayoutConstraint.activate([
            
            sectionStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sectionStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            sectionStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            sectionStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0),
            
            itemTitle.widthAnchor.constraint(equalTo: sectionStackView.widthAnchor, constant: -Const.marginSafeArea * 2),
            itemTitle.topAnchor.constraint(equalTo: sectionStackView.topAnchor, constant: 4.0),
            itemTitle.leadingAnchor.constraint(equalTo: sectionStackView.leadingAnchor, constant: Const.marginSafeArea),
            itemTitle.heightAnchor.constraint(equalToConstant: 50.0),
        ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.backgroundColor = .background
        
        navigationItem.titleView = titleLabelView
        
        // Adds custom leftBarButton
        let backButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            b.tintColor = .primary
            b.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
            return b
        }()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // MARK: Custom functions
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

