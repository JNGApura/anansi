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
import FirebaseAnalytics

// This method parses the JSON right to the Settings model
class NetworkManager {
    
    // Singleton
    static let shared = NetworkManager()
    
    // Databases
    private let userDatabase = Database.database().reference().child("users")
    private let messagesDatabase = Database.database().reference().child("messages")
    private let userMessagesDatabase = Database.database().reference().child("users-messages")
    private let partnerDatabase = Database.database().reference().child("partners")
    private let feedbackDatabase = Database.database().reference().child("feedback")
 
    // MARK: Sign-up / Log-in functions
    
    /// Handles login communication with firebase (Auth)
    func login(email: String, ticket: String, onFail: @escaping (AuthErrorCode) -> Void, onSuccess: @escaping () -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: ticket) { (user, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                onFail(errorCode) // Sends errorCode to LoginController
                return
            }
            
            guard let isEmailVerified = self.isEmailVerified() else { return }
            
            if !isEmailVerified {
                
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                        onFail(errorCode)
                        return
                    }
                }
            }
            
            onSuccess()
        }
    }
    
    /// Handles user creation communication with firebase (authentication)
    func createUserInAuth(email: String, ticket: String, onFail: @escaping (AuthErrorCode) -> Void, onSuccess: @escaping () -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: ticket) { (newUser, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                onFail(errorCode) // Sends errorCode to LoginController
                return
            }
            
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                    onFail(errorCode)
                    return
                }
            }
            
            onSuccess()
        }
    }
    
    /// Handles user creation communication with firebase (database)
    func createUserInDB(email: String, ticket: String, name: String, occupation: String, location: String, onSuccess: @escaping () -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: ticket) { (user, error) in
            if error != nil, let errorCode = AuthErrorCode(rawValue: error!._code) {
                print(errorCode)
                return
            }
            
            // Gets user UID
            guard let uid = self.getUID() else { return }

            // Saves newUser successfully in the database node
            let userReference = self.userDatabase.child(uid)
            userReference.updateChildValues([ userInfoType.email.rawValue: email,
                                              userInfoType.ticket.rawValue: ticket,
                                              userInfoType.name.rawValue: name,
                                              userInfoType.occupation.rawValue: occupation,
                                              userInfoType.location.rawValue: location],
                withCompletionBlock: { (err, userReference) in
                    
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
    func storesImageInStorage(folder: String, image : UIImage, onSuccess: @escaping (String) -> Void) {
        
        let imageName = getUID()
        let storageRef = Storage.storage().reference().child(folder).child("\(imageName!)")
        
        // Compresses image and sends to storageRef
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadImage = image.jpegData(compressionQuality: 0.1) {
            storageRef.putData(uploadImage, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                storageRef.downloadURL(completion: { (imageURL, error) in
                    guard let downloadURL = imageURL else { return }
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    onSuccess("\(downloadURL)")
                })
            }
        }
    }
    
    /// Deletes / removes image from Firebase storage
    func removesImageFromStorage(folder: String, onSuccess: @escaping () -> Void) {
        
        let imageID = getUID()
        let storageRef = Storage.storage().reference().child(folder).child("\(imageID!)")
        
        //Removes image from storage
        storageRef.delete { error in
            if let error = error {
                print(error)
            }
            onSuccess()
        }
    }
    
    // MARK: USER DATABASE FUNCTIONS
    
    /// Gets user UID
    func getUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
        
    /// Gets user UID
    func isEmailVerified() -> Bool? {
        return Auth.auth().currentUser?.isEmailVerified
    }
    
    /// Confirms if user exists in userDatabase
    func isUserCreated(onFail: @escaping () -> Void, onSuccess: @escaping ([String: Any], String) -> Void) {
        
        if let uid = getUID() {
            userDatabase.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
                if !snapshot.exists() { // just to be safe
                    onFail()
                    return
                }
                
                if let dictionary = snapshot.value as? [String: Any] {
                    onSuccess(dictionary, snapshot.key)
                }
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
    
    /// Register dictionary into DB database (user or partner)
    func register(value: Any, for field: String, in id: String) {
        
        userDatabase.child(id).updateChildValues([field : value] as [String : Any]) { (error, userDatabase) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    /// Sets a listener for any changes (DataEventType) to userDatabase (asynchronous), triggered every time the data (including any children) changes.
    //  NOTE: query is ordered by "ranking/views"
    func fetchUsers(onSuccess: @escaping ([String: Any], String) -> Void){
        userDatabase.queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            
            if !snapshot.exists() { return } // just to be safe
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                if dictionary.count > 3 { // NAME, OCCUPATION, LOCATION
                    onSuccess(dictionary, snapshot.key)
                }
            }
        }, withCancel: nil)
    }
    
    func fetchTrendingUsers(limited limit: UInt, onSuccess: @escaping ([String: Any], String) -> Void){
        
        userDatabase.queryOrdered(byChild: "ranking/views").queryLimited(toFirst: limit).observe(.value) { (snapshot) in
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                
                for child in result {
                    
                    let dictionary = child.value as! [String: Any]
                    if dictionary.count > 3 { // NAME, OCCUPATION, LOCATION
                        onSuccess(dictionary, child.key)
                    }
                }
                
            } else {
                print("No results")
            }
        }
    }
    
    /// Observes single event of user from userDatabase
    func fetchUserOnce(userID: String, onSuccess: @escaping ([String: Any]) -> Void){
        
        userDatabase.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            
            if !snapshot.exists() { return }
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                if dictionary.count > 3 { // NAME, OCCUPATION, LOCATION
                    onSuccess(dictionary)
                }
            }
        }
    }
    
    func fetchUser(userID: String, onSuccess: @escaping ([String: Any]) -> Void){
        
        userDatabase.child(userID).observe(.value, with: { (snapshot) in
            if !snapshot.exists() { return }
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                if dictionary.count > 3 { // NAME, OCCUPATION, LOCATION
                    onSuccess(dictionary)
                }
            }
        })
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
    
    /// Updates id's # visualizations (Int) in DB
    func updatesUserViews(id: String) {
        
        userDatabase.child(id).child("ranking/views").runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var value = currentData.value as? Int
            if (value == nil) {
                value = 0
            }
            currentData.value = value! - 1
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    // MARK: - CHAT MESSAGES
    // Post chat message in databse
    func postChatMessageInDB(sender: String, receiver: String, message: [String: Any], onSuccess: @escaping () -> Void) {
        
        let childNode: String
        if sender < receiver { childNode = "\(sender)_\(receiver)" } else { childNode = "\(receiver)_\(sender)" }
        
        messagesDatabase.child(childNode).childByAutoId().updateChildValues(message) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }

            self.userMessagesDatabase.child(sender).updateChildValues([receiver: childNode])
            self.userMessagesDatabase.child(receiver).updateChildValues([sender: childNode])
            
            onSuccess()
        }
    }
    
    // Get list of chat messages from database
    func observeChatMessages(from myID: String, to userID: String, onSuccess: @escaping ([String: Any], String) -> Void) {
        
        userMessagesDatabase.child(myID).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
            if let chatID = snapshot.value as? String {
                
                self.messagesDatabase.child(chatID).observe(.childAdded, with: { (mesg) in
                    
                    guard let dictionary = mesg.value as? [String: Any] else { return }
                    
                    /*
                    if let receiver = mesg.ref.value(forKey: "receiver") as? String, receiver == myID {
                        mesg.ref.updateChildValues(["received" : "true"])
                    }*/
                    
                    onSuccess(dictionary, mesg.key)
                    
                }, withCancel: nil)
            }
            
        }, withCancel: nil)
    }
    
    // Get list of user-messages from database
    func observeChats(from myID: String, onSuccess: @escaping ([String: Any], String) -> Void) {
        
        userMessagesDatabase.child(myID).observe(.childAdded, with: { (snapshot) in
            
            let chatID = snapshot.value as! String

            self.messagesDatabase.child(chatID).observe(.childAdded, with: { (mesg) in
                
                guard var dictionary = mesg.value as? [String: Any] else { return }
                
                if let receiver = dictionary[messageInfoType.receiver.rawValue] as? String, receiver == myID {
                    mesg.ref.updateChildValues([messageInfoType.isDelivered.rawValue : "true"])
                    dictionary.updateValue("true", forKey: messageInfoType.isDelivered.rawValue)
                }
          
                onSuccess(dictionary, mesg.key)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    // Delete user-messages from database
    func deleteChatMessages(from myID: String, to userID: String, onSuccess: @escaping () -> Void) {
        
        userMessagesDatabase.child(myID).child(userID).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete message:", error!)
                return
            }
            onSuccess()
        }
    }
    
    // Mark messages as read
    func markMessagesAs(_ key: String, with messageID: String, from sender: String, to receiver: String, onSuccess: @escaping () -> Void) {
        
        let childNode: String
        if sender < receiver { childNode = "\(sender)_\(receiver)" } else { childNode = "\(receiver)_\(sender)" }
        
        messagesDatabase.child(childNode).child(messageID).updateChildValues([key: "true"]) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            onSuccess()
        }
    }
    
    // Is user typing a message
    func observeTypingInstances(from user: String, onSuccess: @escaping () -> Void, onFail: @escaping () -> Void) {
        
        let myID = getUID()
        
        userDatabase.child(user).child("isTypingTo").onDisconnectRemoveValue()
        
        fetchUser(userID: user) { (dictionary) in
            
            if let chatPartner = dictionary["isTypingTo"] as? String, chatPartner == myID! {
                onSuccess()
            } else {
                onFail()
            }
        }
    }
    
    // MARK: - ANALYTICS Events
    
    func logEvent(name: String, parameters: [String : Any]?) {
        
        Analytics.logEvent(name, parameters: parameters)
    }
    
    // MARK: - FEEDBACK DATABASE

    /// Reports user and stores in DB with reporter ID
    func reportsUserWithMessage(post: [String: Any]) {
        
        feedbackDatabase.child("reports").childByAutoId().setValue(post)
    }
    
    /// Sets value of specific name/key in FeedbackDB
    func setFeedbackValue(post: [String: Any]) {
        
        feedbackDatabase.child("issues").childByAutoId().setValue(post)
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
