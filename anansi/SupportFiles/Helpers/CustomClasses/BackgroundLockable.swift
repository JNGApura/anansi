//
//  BackgroundLockable.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

protocol BackgroundLockable {
    var lockedBackgroundViews: [UIView] { get }
    func performActionWithLockedViews(_ action: @escaping () -> Void)
}

extension BackgroundLockable {
    
    func performActionWithLockedViews(_ action: @escaping () -> Void) {
        let lockedViewToColorMap = lockedBackgroundViews.reduce([:]) { (partialResult, view) -> [UIView: UIColor?] in
            var mutableResult = partialResult
            mutableResult[view] = view.backgroundColor
            return mutableResult
        }
        
        action()
        
        lockedViewToColorMap.forEach { (view: UIView, color: UIColor?) in
            view.backgroundColor = color
        }
    }
}
