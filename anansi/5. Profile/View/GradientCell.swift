//
//  GradientCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class GradientCell: UICollectionViewCell {
    
    // MARK: Custom initializers
    
    var colorOne : UIColor?
    var colorTwo : UIColor?
    
    let gradientView: GradientView = {
        let v = GradientView()
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let checkIcon: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
        i.tintColor = .background
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .background
        
        [gradientView, checkIcon].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 48),
            gradientView.heightAnchor.constraint(equalToConstant: 48),
            
            checkIcon.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 24),
            checkIcon.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let colorOne = colorOne, let colorTwo = colorTwo {
            gradientView.applyGradient(withColours: [colorOne, colorTwo], gradientOrientation: .topLeftBottomRight)
        }
    }
}
