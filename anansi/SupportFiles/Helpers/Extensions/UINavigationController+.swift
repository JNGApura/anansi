//
//  UINavigationController+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 26/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func fadeTo(_ viewController: UIViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromRight
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
    
    func fadeBack() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        view.layer.add(transition, forKey: nil)
        popViewController(animated: false)
    }
}
