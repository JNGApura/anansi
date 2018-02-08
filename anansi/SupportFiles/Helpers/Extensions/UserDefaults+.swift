//
//  UserDefaults+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Adds fours methods to UserDefatuls, to check whether the user has been onboarded and has logged in
extension UserDefaults {
    
    func setIsOnboarded(value: Bool) {
        set(value, forKey: "isOnboarded")
        synchronize()
    }
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: "isLoggedIn")
        synchronize()
    }
    
    func setIsProfiled(value: Bool) {
        set(value, forKey: "isProfiled")
        synchronize()
    }
    
    func isOnboarded() -> Bool {
        return bool(forKey: "isOnboarded")
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: "isLoggedIn")
    }
    
    func isProfiled() -> Bool {
        return bool(forKey: "isProfiled")
    }
}
