//
//  NetworkManager.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 11/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

// This method parses the JSON right to the Settings model
class NetworkManager {
    
    // Singleton
    static let shared = NetworkManager()
    
    // Database's child "settings"
    private var userDatabase = Database.database().reference().child("users")
    
    // Handles login communication with firebase, triggering an onFail or onSuccess action
    func login(email: String, ticket: String, onFail: @escaping (AuthErrorCode) -> Void, onSuccess: @escaping () -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: ticket) { (user, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                onFail(errorCode) // Sends errorCode to LoginController
                return
            }
            onSuccess()
        }
    }
    
    // Handles user creation communication with firebase, triggering an onFail or onSuccess action
    func createUser(email: String, ticket: String, onFail: @escaping (AuthErrorCode) -> Void, onSuccess: @escaping () -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: ticket) { (newUser, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                onFail(errorCode) // Sends errorCode to LoginController
                return
            }
            
            // Gets newUser UID
            guard let uid = newUser?.uid else { return }
            
            // Saves newUser successfully in the database node
            let userReference = self.userDatabase.child(uid)
            userReference.updateChildValues([
                "email": email,
                "ticket": ticket,
                ], withCompletionBlock: { (err, userReference) in
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                onSuccess()
            })
        }
    }
    
    // Signs out user by request
    func logout(onSuccess: @escaping () -> Void) {
        do {
            try
            // Logs user out
            Auth.auth().signOut()
            
            // Sets "isLoggedIn" to false in UserDefaults
            UserDefaults.standard.setIsLoggedIn(value: false)
            
            onSuccess()
            
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    // Sets a listener for any changes (DataEventType) to the database reference (asynchronous), triggered every time the data (including any children) changes.
    /*func loadSettingsData(onSuccess: @escaping (Settings) -> Void){
     
     // The event callback is passed a snapshot containing all data at that location (if that is no data, the value returned is nil).
     settingsDB.observe(DataEventType.value, with: { (snapshot) in
     if !snapshot.exists() { return } // just to be safe
     let dict = snapshot.value as? [String : AnyObject] // snapshot as dictionary of [string: any]
     if let settings = Settings(data: dict) {
     onSuccess(settings)
     }
     })
     }*/
    
}

// Fetches data from JSON file
public func dataFromFile(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return nil
}
