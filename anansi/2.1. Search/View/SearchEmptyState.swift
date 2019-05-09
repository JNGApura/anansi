//
//  SearchEmptyState.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class SearchEmptyState: UIView {
    
    let view: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var viewCenterYAnchor: NSLayoutConstraint?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Find_empty_state").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondary
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let stateTitle: UILabel = {
        let tl = UILabel()
        tl.text = "No results"
        tl.font = UIFont.boldSystemFont(ofSize: Const.headlineFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .center
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let stateDescription: UILabel = {
        let tl = UILabel()
        tl.text = "We couldn't match your search. Try something else."
        tl.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .center
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .background
        
        // Add subviews
        addSubview(view)
        [imageView, stateTitle, stateDescription].forEach { view.addSubview($0) }
        
        // Add layout constraints
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor),
            view.heightAnchor.constraint(equalToConstant: 182.0),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 72.0),
            imageView.heightAnchor.constraint(equalToConstant: 72.0),
            
            stateTitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.0),
            stateTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateTitle.widthAnchor.constraint(equalTo: view.widthAnchor),
            stateTitle.heightAnchor.constraint(equalToConstant: 30.0),
            
            stateDescription.topAnchor.constraint(equalTo: stateTitle.bottomAnchor, constant: 16.0),
            stateDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateDescription.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -132.0),
            //stateDescription.heightAnchor.constraint(equalToConstant: 48.0),
        ])
        
        viewCenterYAnchor = view.centerYAnchor.constraint(equalTo: centerYAnchor)
        viewCenterYAnchor?.isActive = true
    }
}
