//
//  ProfilingPageView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfilingPageView: UIViewController {
    
    // Class initializer
    let page: ProfilingPage

    private let pageTitle: UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .primary
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let pageDescription: UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .secondary
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let pageQuestion: UILabel = {
        let l = UILabel()
        l.text = ""
        l.numberOfLines = 0
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
        
        // Set up description and question
        pageTitle.text = page.title
        pageDescription.text = page.description
        pageDescription.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1.2, hyphenation: 0.5, alignment: .left)
        pageQuestion.text = page.questionTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up stackview
        let stackview : UIStackView = {
            let sv = UIStackView(arrangedSubviews: [pageTitle, pageDescription, pageQuestion])
            sv.axis = .vertical
            sv.distribution = .fill
            sv.translatesAutoresizingMaskIntoConstraints = false
            return sv
        }()
        stackview.setCustomSpacing(Const.marginEight, after: pageTitle)
        stackview.setCustomSpacing(Const.marginSafeArea * 2.0, after: pageDescription)
        
        view.addSubview(stackview)
        view.addSubview(bottomBorderAnswer)
        
        NSLayoutConstraint.activate([
            
            stackview.topAnchor.constraint(equalTo: view.topAnchor),
            stackview.widthAnchor.constraint(equalTo: view.widthAnchor),
            stackview.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            bottomBorderAnswer.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -1.0),
            bottomBorderAnswer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBorderAnswer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorderAnswer.heightAnchor.constraint(equalToConstant: 1.0),
            
        ])
    }
}
