//
//  CustomClasses.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// UIToolbar subclass to add KeyBoardAcessoryToolbar on top of UIToolbar with customizable buttons
class KeyboardAccessoryToolbar: UIToolbar {
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        self.barStyle = .default
        self.isTranslucent = true
        self.tintColor = Color.primary
        self.backgroundColor = Color.tertiary
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        //let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //self.items = [cancelButton, spaceButton, doneButton]
        self.items = [spaceButton, doneButton]
        
        self.isUserInteractionEnabled = true
        self.sizeToFit()
    }
    
    @objc func done() {
        // Tell the current first responder (the current text input) to resign.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @objc func cancel() {
        // Call "cancel" method on first object in the responder chain that implements it.
        UIApplication.shared.sendAction(#selector(cancel), to: nil, from: nil, for: nil)
    }
}

// UILabel subclass to add custom UIEdgeInsets as property to UILabel
class LabelWithInsets : UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 7.0, left: 16.0 + 15.0, bottom: 7.0, right: 16.0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

/*let layer = CAGradientLayer()
 layer.frame = view.layer.frame
 layer.colors = [UIColor.magenta.withAlphaComponent(1).cgColor, UIColor.cyan.withAlphaComponent(0.4).cgColor]
 layer.startPoint = CGPoint(x: 0.23, y: 0.77)
 layer.endPoint = CGPoint(x: 1, y: 0.23)
 view.layer.addSublayer(layer)
 
 let blurEffect = UIBlurEffect(style: .regular)
 let blurEffectView = UIVisualEffectView(effect: blurEffect)
 blurEffectView.frame = self.view.frame
 blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
 view.addSubview(blurEffectView)*/
