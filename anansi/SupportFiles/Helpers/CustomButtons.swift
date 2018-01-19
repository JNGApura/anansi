//
//  CustomButtons.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class PrimaryButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        backgroundColor = Color.primary
        setTitleColor(Color.background, for: .normal)
        layer.cornerRadius = 24.0
        layer.borderWidth = 1.5
        layer.borderColor = Color.primary.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SecondaryButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        backgroundColor = Color.background
        setTitleColor(Color.secondary, for: .normal)
        layer.cornerRadius = 24.0
        layer.borderWidth = 1.5
        layer.borderColor = Color.secondary.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TertiaryButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        backgroundColor = Color.background
        setTitleColor(Color.secondary, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
