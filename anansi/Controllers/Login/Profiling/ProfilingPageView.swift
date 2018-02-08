//
//  ProfilingPageView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfilingPageView: UIViewController, UITextFieldDelegate {
    
    // Class initializer
    let page: ProfilingPage
        
    private let pageDescription: UILabel = {
        let l = UILabel()
        l.textColor = .secondary
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let pageQuestionTitle: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: Const.headlineFontSize)
        l.textColor = .secondary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let bottomBorderAnswer: UIView = {
        let v = UIView()
        v.backgroundColor = .secondary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    init(page: ProfilingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Set description
        pageDescription.text = page.description
        pageDescription.formatTextWithLineSpacing(lineSpacing: 10, lineHeightMultiple: 1.2, hyphenation: 0.5, alignment: .left)
        
        // Set question title
        pageQuestionTitle.text = page.questionTitle
        
        // Adds subviews
        [pageDescription, pageQuestionTitle, bottomBorderAnswer].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            pageDescription.topAnchor.constraint(equalTo: view.topAnchor),
            pageDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginAnchorsToContent),
            pageDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginAnchorsToContent),
            
            pageQuestionTitle.topAnchor.constraint(equalTo: pageDescription.bottomAnchor, constant: 36.0),
            pageQuestionTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginAnchorsToContent),
            pageQuestionTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginAnchorsToContent),
            
            bottomBorderAnswer.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -2.0),
            bottomBorderAnswer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginAnchorsToContent),
            bottomBorderAnswer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginAnchorsToContent),
            bottomBorderAnswer.heightAnchor.constraint(equalToConstant: 2.0),
            
        ])
    }
}
