//
//  OnboardingPageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 16/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class OnboardingPageCell : UICollectionViewCell {
    
    // Custom initializers
    
    var page: OnboardingPage? {
        didSet{
            guard let unwrappedPage = page else { return }
            
            // Set title text
            cellTitle.text = unwrappedPage.title
            cellTitle.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0.5, alignment: .left)
            
            // Set description text
            cellDescription.text = unwrappedPage.description
            cellDescription.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0.5, alignment: .left)
        }
    }
    
    private let cellTitle: UILabel = {
        let title = UILabel()
        title.textColor = .background
        title.numberOfLines = 0
        title.lineBreakMode = NSLineBreakMode.byWordWrapping
        title.font = UIFont.boldSystemFont(ofSize: Const.titleFontSize)
        return title
    }()
    
    private let cellDescription: UILabel = {
        let description = UILabel()
        description.textColor = .background
        description.numberOfLines = 0
        description.lineBreakMode = NSLineBreakMode.byWordWrapping
        description.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        return description
    }()
    
    private let stackView : UIStackView = {
        let ssv = UIStackView()
        ssv.translatesAutoresizingMaskIntoConstraints = false
        ssv.axis = .vertical
        ssv.alignment = .fill
        return ssv
    }()
    
    private let topBorder: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .primary
        return v
    }()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Adds topBorder to pagecell
        //addSubview(topBorder)
        
        // Adds stackView to pagecell
        stackView.addArrangedSubview(cellTitle)
        stackView.addArrangedSubview(cellDescription)
        stackView.setCustomSpacing(Const.marginEight, after: cellTitle)
        addSubview(stackView)
        
        // Sets up layout constraints
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setupLayoutConstraints() {
        
        //let topBorderHeight : CGFloat = 4.0
        
        NSLayoutConstraint.activate([
        
            //topBorder.topAnchor.constraint(equalTo: topAnchor),
            //topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            //topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            //topBorder.heightAnchor.constraint(equalToConstant: topBorderHeight),
            
            stackView.topAnchor.constraint(equalTo: topAnchor), // Const.marginAnchorsToContent * 2 - topBorderHeight
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginAnchorsToContent),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginAnchorsToContent)
        ])
    }
    
}
