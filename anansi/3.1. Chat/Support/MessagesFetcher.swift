//
//  MessagesFetcher.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 26/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

/*
import UIKit
import Firebase

protocol MessagesDelegate: class {
    //func messages(shouldBeUpdatedTo messages: [Message], conversation: Conversation)
    func messages(shouldChangeMessageStatusToReadAt reference: DatabaseReference)
}

protocol CollectionDelegate: class {
    func collectionView(update message: Message, reference: DatabaseReference)
    func collectionView(updateStatus reference: DatabaseReference, message: Message)
}

class MessagesFetcher: NSObject {

}

    private var messages = [Message]()
    
    var userMessagesReference: DatabaseQuery!
    
    var messagesReference: DatabaseReference!
    
    private  let messagesToLoad = 20
    
    private var chatLogAudioPlayer: AVAudioPlayer!
    
    weak var delegate: MessagesDelegate?
    
    weak var collectionDelegate: CollectionDelegate?
    
    var isInitialChatMessagesLoad = true
    
    private var loadingMessagesGroup = DispatchGroup()
    
    private var loadingNamesGroup = DispatchGroup()
    
    func loadMessagesData(for conversation: Conversation) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let conversationID = conversation.chatID else { return }
        
        var isGroupChat = Bool()
        if let groupChat = conversation.isGroupChat, groupChat { isGroupChat = true } else { isGroupChat = false }
        let reference = Database.database().reference().child("user-messages")
        userMessagesReference = reference.child(currentUserID).child(conversationID).child(userMessagesFirebaseFolder)
            .queryLimited(toLast: UInt(messagesToLoad))
        
        loadingMessagesGroup.enter()
        newLoadMessages(reference: userMessagesReference, isGroupChat: isGroupChat)
        
        loadingMessagesGroup.notify(queue: .main, execute: {
            print("loadingMessagesGroup finished")
            
            guard self.messages.count != 0 else {
                self.isInitialChatMessagesLoad = false
                self.delegate?.messages(shouldBeUpdatedTo: self.messages, conversation: conversation)
                return
            }
            
            self.loadingNamesGroup.enter()
            self.newLoadUserames()
            self.loadingNamesGroup.notify(queue: .main, execute: {
                print("loadingNamesGroup finished")
                self.messages = self.sortedMessages(unsortedMessages: self.messages)
                self.isInitialChatMessagesLoad = false
                self.delegate?.messages(shouldChangeMessageStatusToReadAt: self.messagesReference)
                self.delegate?.messages(shouldBeUpdatedTo: self.messages, conversation: conversation)
            })
        })
    }
    
    func newLoadMessages(reference: DatabaseQuery, isGroupChat: Bool) {
        var loadedMessages = [Message]()
        let loadedMessagesGroup = DispatchGroup()
        
        reference.observeSingleEvent(of: .value) { (snapshot) in
            for _ in 0 ..< snapshot.childrenCount { loadedMessagesGroup.enter() }
            
            loadedMessagesGroup.notify(queue: .main, execute: {
                print("loaded messages group finished initial loading messages")
                self.messages = loadedMessages
                self.loadingMessagesGroup.leave()
            })
            reference.observe(.childAdded, with: { (snapshot) in
                let messageUID = snapshot.key
                self.messagesReference = Database.database().reference().child("messages").child(messageUID)
                self.messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard var dictionary = snapshot.value as? [String: AnyObject] else { return }
                    dictionary.updateValue(messageUID as AnyObject, forKey: "messageUID")
                    dictionary = self.preloadCellData(to: dictionary, isGroupChat: isGroupChat)
                    
                    guard self.isInitialChatMessagesLoad else {
                        print("not initial")
                        self.handleMessageInsertionInRuntime(newDictionary: dictionary)
                        return
                    }
                    print("initial")
                    loadedMessages.append(Message(dictionary: dictionary))
                    loadedMessagesGroup.leave()
                })
            })
        }
    }
    
    func handleMessageInsertionInRuntime(newDictionary: [String:AnyObject]) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let message = Message(dictionary: newDictionary)
        let isOutBoxMessage = message.fromId == currentUserID || message.fromId == message.toId
        
        self.loadUserNameForOneMessage(message: message) { [unowned self] (_, messageWithName) in
            if !isOutBoxMessage {
                self.collectionDelegate?.collectionView(update: messageWithName, reference: self.messagesReference)
            } else {
                if let isInformationMessage = message.isInformationMessage, isInformationMessage {
                    self.collectionDelegate?.collectionView(update: messageWithName, reference: self.messagesReference)
                } else {
                    self.collectionDelegate?.collectionView(updateStatus: self.messagesReference, message: messageWithName)
                }
            }
        }
    }
    
    typealias LoadNameCompletionHandler = (_ success: Bool, _ message: Message) -> Void
    func loadUserNameForOneMessage(message: Message, completion: @escaping LoadNameCompletionHandler) {
        guard let senderID = message.fromId else { completion(true, message); return }
        let reference = Database.database().reference().child("users").child(senderID)//.child("name")
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(dictionary: dictionary)
            guard let name = user.name else { completion(true, message); return }
            message.senderName = name
            completion(true, message)
        })
    }
    
    func newLoadUserames() {
        let loadedUserNamesGroup = DispatchGroup()
        
        for _ in messages {
            loadedUserNamesGroup.enter()
            print("names entering")
        }
        
        loadedUserNamesGroup.notify(queue: .main, execute: {
            print("loadedUserNamesGroup group finished ")
            self.loadingNamesGroup.leave()
        })
        
        for index in 0...messages.count - 1 {
            guard let senderID = messages[index].fromId else { print("continuing"); continue }
            let reference = Database.database().reference().child("users").child(senderID)//.child("name")
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let user = User(dictionary: dictionary)
                guard let name = user.name else {  loadedUserNamesGroup.leave(); return }
                self.messages[index].senderName = name
                loadedUserNamesGroup.leave()
                print("names leaving")
            })
        }
    }
    
    func sortedMessages(unsortedMessages: [Message]) -> [Message] {
        let sortedMessages = unsortedMessages.sorted(by: { (message1, message2) -> Bool in
            return message1.timestamp!.int32Value < message2.timestamp!.int32Value
        })
        return sortedMessages
    }
}*/
