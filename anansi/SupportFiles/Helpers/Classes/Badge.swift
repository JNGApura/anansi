//
//  Badge.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Creates badge with no artifact around the outside of the border
class Badge : UIView {
    
    class Mask : UIView {
        
        override init(frame:CGRect) {
            super.init(frame:frame)
            self.isOpaque = false
            self.backgroundColor = .clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let con = UIGraphicsGetCurrentContext()!
            con.fillEllipse(in: CGRect(origin:.zero, size:rect.size))
        }
    }
    
    let innerColor : UIColor
    
    let outerColor : UIColor
    
    let innerRadius : CGFloat
    
    var madeMask = false
    
    init(frame:CGRect, innerColor:UIColor, outerColor:UIColor, innerRadius:CGFloat) {
        self.innerColor = innerColor
        self.outerColor = outerColor
        self.innerRadius = innerRadius
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let con = UIGraphicsGetCurrentContext()!
        con.setFillColor(outerColor.cgColor)
        con.fill(rect)
        con.setFillColor(innerColor.cgColor)
        con.fillEllipse(in: CGRect(x: rect.midX-innerRadius, y: rect.midY-innerRadius, width: 2*innerRadius, height: 2*innerRadius))
        
        if !self.madeMask {
            self.madeMask = true // do only once
            self.mask = Mask(frame:CGRect(origin:.zero, size:rect.size))
        }
    }
}
