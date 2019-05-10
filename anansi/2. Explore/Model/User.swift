//
//  User.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 19/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

enum userInfoType: String {
    case id = "id"
    case email = "email"
    case ticket = "ticket"
    case profileImageURL = "profileImageURL"
    case name = "name"
    case occupation = "occupation"
    case location = "location"
    case bio = "bio"
    case interests = "interests"
    case tedTitle = "tedTitle"
    case sharedEmail = "sharedEmail"
    case website = "website"
    case linkedin = "linkedin"
    case blockedUsers = "blockedUsers"
    case ranking = "ranking"
}

enum userInfoSection: String {
    case about = "About me"
    case tedTalk = "Favorite TED talk"
    case contactInfo = "Contact information"
}

class User: NSObject {
    
    // MARK: Properties
    private var id: String!
    private var email: String!
    private var ticket: String!
    private var location: String!
    private var occupation: String!
    private var name: String!
    private var profileImageURL: String!
    private var bio: String!
    private var interests: [String]!
    private var tedTitle: String!
    private var sharedEmail: String!
    private var website: String!
    private var linkedin: String!
    private var blockedUsers: [String: String]!
    private var ranking: [String : Int]!
    
    
    // MARK: NSCoding Encoding
    /*
    func encode(with aCoder: NSCoder) {
        
        let dictionary = createDict()
        aCoder.encode(dictionary, forKey: "dictionary")
    }
    
    // MARK: NSCoding Decoding
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()
        
        if let dic = aDecoder.decodeObject(forKey: "dictionary") as? [String: Any] {
            let id = dic["id"] as! String
            set(dictionary: dic, id: id)
        }
    }*/
    
    // MARK: Initialization
    override init () {
        super.init()
    }
    
    func set(dictionary: [String: Any], id: String) {
        
        setValue(value: id, for: userInfoType.id)
        
        for item in dictionary {
            
            if let infoType = userInfoType(rawValue: item.key) {
                setValue(value: item.value, for: infoType)
            }
        }
    }
    
    func createDict() -> [String: Any] {
        
        var dictionary : [String : Any] = [:]
        for element in iterateEnum(userInfoType.self) {
            dictionary[element.rawValue] = getValue(forField: element)
        }
        
        return dictionary
    }
    
    func saveInDisk(value: Any, for field: userInfoType) {
        
        UserDefaults.standard.set(value, forKey: field.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // Sets value for field
    func setValue(value: Any, for field: userInfoType) {
        
        switch field {
        case .id:
            if let id = value as? String { self.id = id }
        case .email:
            if let email = value as? String { self.email = email }
        case .ticket:
            if let ticket = value as? String { self.ticket = ticket }
        case .name:
            if let name = value as? String { self.name = name }
        case .occupation:
            if let occupation = value as? String { self.occupation = occupation}
        case .location:
            if let location = value as? String { self.location = location}
        case .profileImageURL:
            if let profileImageURL = value as? String { self.profileImageURL = profileImageURL }
        case .bio:
            if let bio = value as? String { self.bio = bio }
        case .interests:
            if let interests = value as? [String] { self.interests = interests }
        case .tedTitle:
            if let tedTitle = value as? String { self.tedTitle = tedTitle }
        case .sharedEmail:
            if let sharedEmail = value as? String { self.sharedEmail = sharedEmail}
        case .website:
            if let website = value as? String { self.website = website }
        case .linkedin:
            if let linkedin = value as? String { self.linkedin = linkedin }
        case .blockedUsers:
            if let blockedUsers = value as? [String : String] { self.blockedUsers = blockedUsers}
        case .ranking:
            if let ranking = value as? [String : Int] {self.ranking = ranking}
        }
    }
    
    // Sets value for field
    func removeValue(for field: userInfoType) {
        
        switch field {
        case .id:
            self.id = nil
        case .email:
            self.email = nil
        case .ticket:
            self.ticket = nil
        case .name:
            self.name = nil
        case .occupation:
            self.occupation = nil
        case .location:
            self.location = nil
        case .profileImageURL:
            self.profileImageURL = nil
        case .bio:
            self.bio = nil
        case .interests:
            self.interests = nil
        case .tedTitle:
            self.tedTitle = nil
        case .sharedEmail:
            self.sharedEmail = nil
        case .website:
            self.website = nil
        case .linkedin:
            self.linkedin = nil
        case .blockedUsers:
            self.blockedUsers = nil
        case .ranking:
            self.ranking = nil
        }
    }
    
    // Gets value for field
    func getValue(forField field: userInfoType) -> Any {
        
        switch field {
        case .id: return id
        case .email: return email
        case .ticket: return ticket
        case .name: return name
        case .occupation: return occupation
        case .location: return location
        case .profileImageURL: return profileImageURL
        case .bio: return bio
        case .interests: return interests
        case .tedTitle: return tedTitle
        case .sharedEmail: return sharedEmail
        case .website: return website
        case .linkedin: return linkedin
        case .blockedUsers: return blockedUsers
        case .ranking: return ranking
        }
    }
    
    // Gets label for specific field / property
    func label(forField field: userInfoType) -> String {
        
        switch field {
        case .id: return "userID"
        case .email: return "Email"
        case .ticket: return "Ticket reference"
        case .name: return "Your name"
        case .occupation: return "What you do"
        case .location: return "Where you live"
        case .profileImageURL: return "Profile image"
        case .bio: return "My short biography"
        case .interests: return "My interests"
        case .tedTitle: return "Title and speaker"
        case .sharedEmail: return "Public email address"
        case .website: return "Website"
        case .linkedin: return "LinkedIn profile"
        case .blockedUsers: return "Blocked users"
        case .ranking: return "View ranking"
        }
    }
    
    // Gets placeholder for specific field / property
    func placeholder(forField field: userInfoType) -> String {
        
        switch field {
        case .id: return "User identificator"
        case .email: return "Your email"
        case .ticket: return "Your ticket reference"
        case .name: return "First and last name"
        case .occupation: return "E.g. dream catcher"
        case .location: return "E.g. Atlantis"
        case .profileImageURL: return "Your profile picture"
        case .bio: return "Say something about yourself"
        case .interests: return "Your interests go here"
        case .tedTitle: return "One that gives you chills"
        case .sharedEmail: return "Public email address"
        case .website: return "https://"
        case .linkedin: return "linkedin.com/in/"
        case .blockedUsers: return "Blocked Users"
        case .ranking: return "View ranking"
        }
    }
    
    func reset() {
        self.id = nil
        self.email = nil
        self.ticket = nil
        self.name = nil
        self.occupation = nil
        self.location = nil
        self.profileImageURL = nil
        self.bio = nil
        self.interests = nil
        self.tedTitle = nil
        self.sharedEmail = nil
        self.website = nil
        self.linkedin = nil
        self.blockedUsers = nil
        self.ranking = nil
    }
}


/*
 // MARK: - Hashable/Equatable
 override var hash: Int { return ID.hash }
 override var hashValue: Int { return ID.hashValue }
 override func isEqual(_ object: Any?) -> Bool {
 guard let otherPerson = object as? Mom else { return false }
 return otherPerson == self
 }
 
 static var _dateFormatter: DateFormatter?
 fileprivate static var dateFormatter: DateFormatter {
 if (_dateFormatter == nil) {
 _dateFormatter = DateFormatter()
 _dateFormatter!.locale = Locale(identifier: "en_US_POSIX")
 _dateFormatter!.dateFormat = "MM/dd/yyyy"
 }
 return _dateFormatter!
 }
 static func dateFromString(dateString: String) -> Date? {
 return dateFormatter.date(from: dateString)
 }
 static func dateStringFromDate(date: Date) -> String {
 return dateFormatter.string(from: date)
 }*/
