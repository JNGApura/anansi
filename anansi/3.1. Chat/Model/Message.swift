//
//  Message.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

enum messageInfoType: String {
    case id = "id"
    case timestamp = "createdAt"
    case sender = "sender"
    case receiver = "receiver"
    case text = "message"
    case isSent = "sent"
    case isDelivered = "received"
    case isRead = "read"
}

class Message: NSObject {
    
    // MARK: Properties
    private var id: String!
    private var timestamp: NSNumber!
    private var sender: String!
    private var receiver: String!
    private var text: String!
    private var isSent: Bool!
    private var isDelivered: Bool!
    private var isRead: Bool!
    
    // MARK: Initialization
    init(dictionary: [String: Any], messageID: String) {
        super.init()
        
        setValue(value: messageID, for: messageInfoType.id)
        
        for item in dictionary {
            if let infoType = messageInfoType(rawValue: item.key) {
                setValue(value: item.value, for: infoType)
            }
        }
    }
    
    // Sets value for field
    func setValue(value: Any, for field: messageInfoType) {
        
        switch field {
        case .id:
            if let id = value as? String { self.id = id }
        case .timestamp:
            if let timestamp = value as? String { self.timestamp = convertToTimestamp(string: timestamp) as NSNumber}
        case .sender:
            if let sender = value as? String { self.sender = sender }
        case .receiver:
            if let receiver = value as? String { self.receiver = receiver }
        case .text:
            if let text = value as? String { self.text = text }
        case .isSent:
            if let isSent = value as? String { self.isSent = NSString(string: isSent).boolValue }
        case .isDelivered:
            if let isDelivered = value as? String { self.isDelivered = NSString(string: isDelivered).boolValue }
        case .isRead:
            if let isRead = value as? String { self.isRead = NSString(string: isRead).boolValue }
        }
    }
    
    // Gets value for field
    func getValue(forField field: messageInfoType) -> Any {
        
        switch field {
        case .id: return id
        case .timestamp: return timestamp
        case .sender: return sender
        case .receiver: return receiver
        case .text: return text
        case .isSent: return isSent
        case .isDelivered: return isDelivered
        case .isRead: return isRead
        }
    }
    
    func partnerID() -> String? {
        return sender == NetworkManager.shared.getUID() ? receiver : sender
    }
    
    func convertToTimestamp(string: String) -> TimeInterval {
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyyMMdd_HHmmss"
        let date = dfmatter.date(from: string)
        
        return date!.timeIntervalSince1970
    }
}
