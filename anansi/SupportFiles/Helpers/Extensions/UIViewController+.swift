//
//  UIViewController+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

extension UIViewController {

    // Close iOS Keyboard by touching anywhere in the viewController
    func hideKeyboardWhenTappedAround(cancelsTouches : Bool = false) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = cancelsTouches
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
