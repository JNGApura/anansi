//
//  NetworkManager.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 11/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation
import FirebaseDatabase

// This method parses the JSON right to the Settings model
class NetworkManager {
    
    // Singleton
    static let shared = NetworkManager()
    
    // Accesses database's child "settings"
    private var settingsDB = Database.database().reference().child("settings")
    
    // Sets a listener for any changes (DataEventType) to the database reference (asynchronous), triggered every time the data (including any children) changes. The event callback is passed a snapshot containing all data at that location (if that is no data, the value returned is nil).
    func loadSettingsData(onSuccess: @escaping (Settings) -> Void){
        settingsDB.observe(DataEventType.value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let dict = snapshot.value as? [String : AnyObject]
            if let settings = Settings(data: dict) {
                onSuccess(settings)
            }
        })
    }
}
