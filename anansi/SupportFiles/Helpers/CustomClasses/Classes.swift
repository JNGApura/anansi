//
//  CustomClasses.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// UILabel subclass to add custom UIEdgeInsets as property to UILabel
class LabelWithInsets : UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 7.0, left: 16.0 + 15.0, bottom: 7.0, right: 16.0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
