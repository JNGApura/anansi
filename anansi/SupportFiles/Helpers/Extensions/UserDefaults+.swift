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
    
    // General app
    
    func setOnboarded(value: Bool) {
        set(value, forKey: "isOnboarded")
        synchronize()
    }
    
    func setLoggedIn(value: Bool) {
        set(value, forKey: "isLoggedIn")
        synchronize()
    }
    
    func setProfiled(value: Bool) {
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
    
    // Specific screens
    
    func setCommunityOnboarded(value: Bool) {
        set(value, forKey: "isCommunityOnboarded")
        synchronize()
    }
    
    func setConnectOnboarded(value: Bool) {
        set(value, forKey: "isConnectOnboarded")
        synchronize()
    }
    
    func setEventOnboarded(value: Bool) {
        set(value, forKey: "isEventOnboarded")
        synchronize()
    }
    
    func setProfileOnboarded(value: Bool) {
        set(value, forKey: "isProfileOnboarded")
        synchronize()
    }
    
    func isCommunityOnboarded() -> Bool {
        return bool(forKey: "isCommunityOnboarded")
    }
    
    func isConnectOnboarded() -> Bool {
        return bool(forKey: "isConnectOnboarded")
    }
    
    func isEventOnboarded() -> Bool {
        return bool(forKey: "isEventOnboarded")
    }
    
    func isProfileOnboarded() -> Bool {
        return bool(forKey: "isProfileOnboarded")
    }
}
