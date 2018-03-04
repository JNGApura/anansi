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
import FirebaseStorage

// This method parses the JSON right to the Settings model
class NetworkManager {
    
    // Singleton
    static let shared = NetworkManager()
    
    // Databases
    private let userDatabase = Database.database().reference().child("users")
    private let partnerDatabase = Database.database().reference().child("partners")
    private let messagesDatabase = Database.database().reference().child("messages")
    private let userMessagesDatabase = Database.database().reference().child("user-messages")
    private let feedbackDatabase = Database.database().reference().child("feedback")
 
    // MARK: Sign-up / Log-in functions
    
    /// Handles login communication with firebase, triggering an onFail or onSuccess action
    func login(email: String, ticket: String, onFail: @escaping (AuthErrorCode) -> Void, onSuccess: @escaping () -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: ticket) { (user, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                onFail(errorCode) // Sends errorCode to LoginController
                return
            }
            onSuccess()
        }
    }
    
    /// Handles user creation communication with firebase, triggering an onFail or onSuccess action
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
    
    /// Signs out user by request
    func logout(onSuccess: @escaping () -> Void) {
        do {
            try
            // Logs user out
            Auth.auth().signOut()
            
            // Sets "isLoggedIn" to false in UserDefaults
            UserDefaults.standard.setLoggedIn(value: false)
            
            onSuccess()
            
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    /// Stores image in Firebase storage
    func storesImageInDatabase(folder: String, image : UIImage, onSuccess: @escaping (String) -> Void) {
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(folder).child("\(imageName).png")
        
        // Compresses image and sends to storageRef
        if let uploadImage = UIImageJPEGRepresentation(image, 0.1) {
            storageRef.putData(uploadImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                // Fetches the absolute URL string
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    onSuccess(imageURL)
                }
            })
        }
    }
    
    // MARK: USER DATABASE FUNCTIONS
    
    /// Gets user UID
    func getUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// Confirms if user exists in userDatabase
    func isUserLoggedIn(onSuccess: @escaping ([String: Any], String) -> Void) {
        
        if let uid = getUID() {
            userDatabase.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
                if !snapshot.exists() { return } // just to be safe
                if let dictionary = snapshot.value as? [String: Any] {
                    onSuccess(dictionary, snapshot.key)
                }
            }
        }
    }
    
    /// Sets a listener for any changes (DataEventType) to userDatabase (asynchronous), triggered every time the data (including any children) changes.
    //  NOTE: query is ordered by "name"
    func fetchUsers(onSuccess: @escaping ([String: Any], String) -> Void){
        userDatabase.queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            
            if !snapshot.exists() { return } // just to be safe
            if let dictionary = snapshot.value as? [String: Any] {
                onSuccess(dictionary, snapshot.key)
            }
        }, withCancel: nil)
    }
    
    /// Observes single event of user from userDatabase
    func fetchUser(userID: String, onSuccess: @escaping ([String: Any]) -> Void){
        userDatabase.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() { return }
            if let dictionary = snapshot.value as? [String: Any] {
                onSuccess(dictionary)
            }
        }
    }
    
    /// Sets a listener for any changes (DataEventType) to userDatabase (asynchronous), triggered every time the data (including any children) changes.
    //  NOTE: query is ordered by "order"
    func fetchPartners(onSuccess: @escaping ([String: Any], String) -> Void){
        partnerDatabase.queryOrdered(byChild: "order").observe(.childAdded, with: { (snapshot) in
                        
            if !snapshot.exists() { return } // just to be safe
            if let dictionary = snapshot.value as? [String: Any] {
                onSuccess(dictionary, snapshot.key)
            }
        }, withCancel: nil)
    }
    
    /// Register dictionary into DB database (user or partner)
    func registerUserInDB(dictionary: [String: Any]) {
        
        if let uid = getUID() {
            userDatabase.child(uid).updateChildValues(dictionary) { (error, userDatabase) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
            }
        }
    }
    
    // FUNCTION TO BE REMOVED!
    func registerPartnerInDB(dictionary: [String: Any]) {

        partnerDatabase.childByAutoId().updateChildValues(dictionary) { (error, partnerDatabase) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    /// Remove dictionary from database
    func removeData(_ key: String) {
        
        //let node = [name: value] // [String: Any]
        if let uid = getUID() {
            userDatabase.child(uid).child(key).removeValue()
        }
    }
    
    /// Updates User's ranking (Int) in DB database
    func updatesUserRanking(userID: String, property: String) {
        
        userDatabase.child(userID).child(property).runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var value = currentData.value as? Int
            if (value == nil) {
                value = 0
            }
            currentData.value = value! + 1
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    /// Updates Partner's ranking (Int) in DB database
    func updatesPartnerRanking(partnerID: String, property: String) {
        
        partnerDatabase.child(partnerID).child(property).runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var value = currentData.value as? Int
            if (value == nil) {
                value = 0
            }
            currentData.value = value! + 1
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    
    // MARK: FEEDBACK DATABASE FUNCTIONS
    
    /// Updates Int of specific name/key in FeedbackDB
    func updatesFeedbackValue(name: String) {
    
        feedbackDatabase.child(name).runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var value = currentData.value as? Int
            if (value == nil) {
                value = 0
            }
            currentData.value = value! + 1
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    /// Sets value of specific name/key in FeedbackDB
    func setFeedbackValue(name: String, post: [String: Any]) {
        
        feedbackDatabase.child(name).childByAutoId().setValue(post)
    }
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
