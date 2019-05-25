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
    
    /// Remove data in DB from my UID child
    func removeData(_ key: String, in uid: String) {
        
        userDatabase.child(uid).child(key).removeValue()
    }
    
    /// Register dictionary into DB database (user or partner)
    func register(value: Any, for field: String, in id: String) {
        
        userDatabase.child(id).updateChildValues([field : value] as [String : Any]) { (error, userDatabase) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }
        
        if field == userInfoType.isTyping.rawValue {
            userDatabase.child(id).child(field).onDisconnectRemoveValue()
        }
    }
    
    /// Sets a listener for any changes (DataEventType) to userDatabase (asynchronous), triggered every time the data (including any children) changes.
    //  NOTE: query is ordered by "name"
    func fetchUsers(onAdd: (([String: Any], String) -> Void)?,
                    onChange: (([String: Any], String) -> Void)?,
                    onRemove: (([String: Any], String) -> Void)?) {
        
        DispatchQueue.main.async {
            
            self.userDatabase.observe(.childAdded) { (snapshot) in
                
                if !snapshot.exists() { return }
                if let user = snapshot.value as? [String: Any] {
                    
                    if user.count > 3 { // NAME, OCCUPATION, LOCATION
                        onAdd?(user, snapshot.key)
                    }
                }
            }
        
            self.userDatabase.observe(.childChanged) { (snapshot) in
                
                if !snapshot.exists() { return }
                if let user = snapshot.value as? [String: Any] {
                    
                    if user.count > 3 { // NAME, OCCUPATION, LOCATION
                        onChange?(user, snapshot.key)
                    }
                }
            }
            
            self.userDatabase.observe(.childRemoved) { (snapshot) in
                
                if !snapshot.exists() { return }
                if let user = snapshot.value as? [String: Any] {
                    
                    if user.count > 3 { // NAME, OCCUPATION, LOCATION
                        onRemove?(user, snapshot.key)
                    }
                }
            }
        }
    }
    
    func fetchTrendingUsers(limited limit: UInt, onSuccess: @escaping ([String: Any], String) -> Void){
        
        userDatabase.queryOrdered(byChild: "ranking/views").queryLimited(toFirst: limit).observe(.value, with: { (snapshot) in
            
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
        })
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
    
    /// Fetches user from userDatabase
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
    
    /// Sets a listener for any changes (DataEventType) to userDatabase (asynchronous), triggered every time data is changes.
    //  NOTE: query is ordered by "order"
    func fetchPartners(onAdd: @escaping ([String: Any], String) -> Void,
                       onChange: @escaping ([String: Any], String) -> Void,
                       onRemove: @escaping ([String: Any], String) -> Void){
        
        partnerDatabase.queryOrdered(byChild: "order").observe(.childAdded) { (snapshot) in
            
            if !snapshot.exists() { return }
            if let partner = snapshot.value as? [String: Any] {
                onAdd(partner, snapshot.key)
            }
        }
        
        partnerDatabase.queryOrdered(byChild: "order").observe(.childChanged) { (snapshot) in
            
            if !snapshot.exists() { return }
            if let partner = snapshot.value as? [String: Any] {
                onChange(partner, snapshot.key)
            }
        }
        
        partnerDatabase.queryOrdered(byChild: "order").observe(.childRemoved) { (snapshot) in
            
            if !snapshot.exists() { return }
            if let partner = snapshot.value as? [String: Any] {
                onRemove(partner, snapshot.key)
            }
        }
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

    // Checks if user has conversations in Firebase
    func observeExistingConversations(from myID: String,
                                      onAdd: ((String, String) -> Void)?,
                                      onRemove: ((String, String) -> Void)?,
                                      noConversations: (() -> Void)?) {
        
        userMessagesDatabase.child(myID).observeSingleEvent(of: .value) { (snapshot) in
            
            if !snapshot.hasChildren() {
                noConversations?()
            }
        }
        
        userMessagesDatabase.child(myID).observe(.childAdded) { (snapshot) in
            
            if !snapshot.exists() { return }
            if let chatID = snapshot.value as? String {
                onAdd?(chatID, snapshot.key)
            }
        }

        userMessagesDatabase.child(myID).observe(.childRemoved) { (snapshot) in
            
            if !snapshot.exists() { return }
            if let chatID = snapshot.value as? String {
                onRemove?(chatID, snapshot.key)
            }
        }
    }
    
    // TO DO: CHECK IF THIS IS THE RIGHT WAY TO DO IT
    // Get list of messages from a conversation
    func observeConversation(withID chatID: String,
                             onAdd: (([String: Any], String) -> Void)?,
                             onChange: (([String: Any], String) -> Void)?,
                             onRemove: (([String: Any], String) -> Void)?) {
        
        messagesDatabase.child(chatID).observe(.childAdded) { (dic) in
            
            guard let message = dic.value as? [String: Any] else { return }
            onAdd?(message, dic.key)
        }
        
        messagesDatabase.child(chatID).observe(.childChanged) { (dic) in
            
            guard let message = dic.value as? [String: Any] else { return }
            onChange?(message, dic.key)
        }
        
        messagesDatabase.child(chatID).observe(.childRemoved) { (dic) in
            
            guard let message = dic.value as? [String: Any] else { return }
            onRemove?(message, dic.key)
        }
    }
    
    // Create childnode for userMessages
    
    func childNode(_ sender: String, _ receiver: String) -> String {
        return sender < receiver ? "\(sender)_\(receiver)" : "\(receiver)_\(sender)"
    }
    
    // Create node in userMessages database
    func createsUserMessageNode(sender: String, receiver: String, onSuccess: (() -> Void)?) {
        
        let childNode = self.childNode(sender, receiver)
        
        userMessagesDatabase.child(sender).updateChildValues([receiver: childNode])
        userMessagesDatabase.child(receiver).updateChildValues([sender: childNode])
        
        onSuccess?()
    }
    
    // Post chat message in databse
    func postChatMessageInDB(sender: String, receiver: String, message: [String: Any], onSuccess: (() -> Void)?) {
        
        let childNode = self.childNode(sender, receiver)
        
        messagesDatabase.child(childNode).childByAutoId().updateChildValues(message) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.userMessagesDatabase.child(sender).observeSingleEvent(of: .value) { (snapshot) in
                if !snapshot.hasChildren() {
                    ref.updateChildValues([receiver: childNode])
                }
            }
            
            self.userMessagesDatabase.child(receiver).observeSingleEvent(of: .value) { (snapshot) in
                if !snapshot.hasChildren() {
                    ref.updateChildValues([sender: childNode])
                }
            }
            
            onSuccess?()
        }
    }
    
    // Mark messages as read
    func markMessagesAs(_ key: String, withID messageID: String, from sender: String, to receiver: String, onSuccess: (() -> Void)?) {
        
        let childNode = self.childNode(sender, receiver)
        
        messagesDatabase.child(childNode).child(messageID).updateChildValues([key: "true"]) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            onSuccess?()
        }
    }
    
    // Adds reaction to message
    func registerReaction(_ reaction: String, for messageID: String, to sender: String, from receiver: String, onSuccess: @escaping () -> Void) {
        
        let childNode = self.childNode(sender, receiver)
        
        messagesDatabase.child(childNode).child(messageID).child("hasReaction").updateChildValues([receiver: reaction]) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            onSuccess()
        }
    }
    
    // Is user typing a message
    func observeTypingInstances(from userID: String, onTyping: (() -> Void)?, onNotTyping: (() -> Void)?) {
        
        userDatabase.child(userID).child(userInfoType.isTyping.rawValue).observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                onTyping?()
            } else {
                onNotTyping?()
            }
        }
    }
    
    // Delete user-messages from database
    func deleteUserMessageNode(from myID: String, to userID: String, onDelete: (() -> Void)?) {
        
        userMessagesDatabase.child(myID).child(userID).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete conversations: ", error!)
                return
            }
            onDelete?()
        }
    }
    
    // Delete / unsend a message from databse
    func deleteMessage(with msgID: String, from sender: String, to receiver: String, onDelete: (() -> Void)?) {
        
        let childNode: String
        if sender < receiver { childNode = "\(sender)_\(receiver)" } else { childNode = "\(receiver)_\(sender)" }
        
        messagesDatabase.child(childNode).child(msgID).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete message: ", error!)
                return
            }
            onDelete?()
        }
    }
    
    // Removes reaction from message
    func removeReaction(_ reaction: String, for messageID: String, to sender: String, from receiver: String, onDelete: (() -> Void)?) {
        
        let childNode = self.childNode(sender, receiver)
        
        messagesDatabase.child(childNode).child(messageID).child("hasReaction").child(receiver).removeValue { (error, ref) in
            if error != nil {
                print("Failed to remove reaction: ", error!)
                return
            }
            onDelete?()
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
