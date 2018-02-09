//
//  CustomButtons.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Primary button, subclassed from UIButton
class PrimaryButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        backgroundColor = .primary
        setTitleColor(.background, for: .normal)
        layer.cornerRadius = 24.0
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.primary.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Secondary button, subclassed from UIButton
class SecondaryButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        backgroundColor = .background
        setTitleColor(.secondary, for: .normal)
        layer.cornerRadius = 24.0
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.secondary.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Tertiary button, subclassed from UIButton
class TertiaryButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        backgroundColor = .background
        setTitleColor(.secondary, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
