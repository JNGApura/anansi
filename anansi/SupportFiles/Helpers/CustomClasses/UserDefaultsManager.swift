//
//  UserDefaultsManager.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

let userDefaults = UserDefaultsManager()

class UserDefaultsManager: NSObject {
    
    fileprivate let standard = UserDefaults.standard
    
    let hasRunBefore = "hasRunBefore"
    let isOnboarded = "isOnboarded"
    let isLoggedIn = "isLoggedIn"
    let isProfiled = "isProfiled"
    let isCommunityOnboarded = "isCommunityOnboarded"
    let isConnectOnboarded = "isConnectOnboarded"
    let isEventOnboarded = "isEventOnboarded"
    let isProfileOnboarded = "isProfileOnboarded"
    let wasOfflineAlertShown = "wasOfflineAlertShown"
    let recentlyViewedIDs = "recentlyViewedIDs"

    // Updating object
    func updateObject(for key: String, with value: Any?) {
        standard.set(value, forKey: key)
        standard.synchronize()
    }
    
    // Removing object
    func removeObject(for key: String) {
        standard.removeObject(forKey: key)
    }
    
    func string(for key: String) -> String? {
        return standard.string(forKey: key)
    }
    
    func stringList(for key: String) -> [String]? {
        return standard.value(forKey: key) as? [String]
    }
    
    func int(for key: String) -> Int? {
        return standard.integer(forKey: key)
    }
    
    func bool(for key: String) -> Bool {
        return standard.bool(forKey: key)
    }
    
    func configureInitialLaunch() {
        
        if standard.bool(forKey: hasRunBefore) != true {
            NetworkManager.shared.logout(onSuccess: nil)
            updateObject(for: hasRunBefore, with: true)
        }
    }
}
