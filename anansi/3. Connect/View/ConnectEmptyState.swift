//
//  ConnectEmptyState.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ConnectEmptyState: UIView {
    
    var placeholder : String! {
        didSet {
            
            let index = Const.emptystateTitle.index(of: placeholder)
            
            stateTitle.text = placeholder
            stateDescription.text = Const.emptystateSubtitle[index!]
            imageView.image = UIImage(named: "Connect-empty-\(index!)")!.withRenderingMode(.alwaysOriginal)            
        }
    }
    
    let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondary
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let stateTitle: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: 20.0)
        tl.textColor = .secondary
        tl.textAlignment = .center
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let stateDescription: UILabel = {
        let tl = UILabel()
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
        [imageView, stateTitle, stateDescription].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSpacing(Const.marginEight * 2.0, after: imageView)
        stackView.setCustomSpacing(Const.marginEight, after: stateTitle)
        addSubview(stackView)
        
        // Add layout constraints
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Const.marginSafeArea * 2.0),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 5.5),
            
        ])
    }
}
