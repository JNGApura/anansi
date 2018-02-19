//
//  User.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 19/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class User: NSObject {
    
    // Sign-up
    var id: String?
    var email: String?
    var ticketReference: String?
    
    // Profiling/on-boarding questions
    var location: String?
    var occupation: String?
    var name: String?
    
    // From profile page
    var profileImageURL: String?
    var bio: String?
    
    // Interests
    var interests: [String]?
    
    // Favourite TED talk
    var TEDtitle: String?
    var TEDspeaker: String?
    
    // Contact information
    var sharedEmail: String?
    var website: String?
    var linkedin: String?
    
    // App color
    var gradientColor: Int?
    
    // Store dictionary - for future reference, if needed
    var dictionary: [String: Any]?
    
    init(dictionary: [String: Any], id: String) {
        
        self.id = id
        self.email = dictionary["email"] as? String
        self.ticketReference = dictionary["ticket"] as? String
        
        self.location = dictionary["location"] as? String
        self.occupation = dictionary["occupation"] as? String
        self.name = dictionary["name"] as? String
        
        self.profileImageURL = dictionary["profileImageURL"] as? String
        self.bio = dictionary["bio"] as? String
        
        self.interests = dictionary["interests"] as? [String]
        
        self.TEDtitle = dictionary["TEDtitle"] as? String
        self.TEDspeaker = dictionary["TEDspeaker"] as? String
        
        self.sharedEmail = dictionary["sharedEmail"] as? String
        self.website = dictionary["website"] as? String
        self.linkedin = dictionary["linkedin"] as? String
        
        self.gradientColor = dictionary["gradientColor"] as? Int
        
        self.dictionary = dictionary
    }
    
    // Methods
    
    func setProfileImageURL(with url: String) {
        self.profileImageURL = url
    }
    
    func setGradientColor(with option: Int) {
        self.gradientColor = option
    }
    
    func updateInterestList(with list: [String]) {
        self.interests = list
    }
    
    func set(value: String, forKey key: String) {
        
        self.dictionary?.updateValue(value, forKey: key)
        
        switch key {
            
        case "name":
            self.name = value
            
        case "occupation":
            self.occupation = value
            
        case "location":
            self.location = value
            
        case "bio":
            self.bio = value
            
        case "TEDtitle":
            self.TEDtitle = value
            
        case "TEDspeaker":
            self.TEDspeaker = value
            
        case "sharedEmail":
            self.sharedEmail = value
            
        case "website":
            self.website = value
            
        case "linkedin":
            self.linkedin = value
            
        default:
            print("nope")
        }
    }
    
    func remove(value: String, forKey key: String) {
        
        self.dictionary?.removeValue(forKey: key)
        
        switch key {
            
        case "bio":
            self.bio = nil
            
        case "TEDtitle":
            self.TEDtitle = nil
            
        case "TEDspeaker":
            self.TEDspeaker = nil
            
        case "sharedEmail":
            self.sharedEmail = nil
            
        case "website":
            self.website = nil
            
        case "linkedin":
            self.linkedin = nil
            
        default:
            print("nope")
        }
    }
    
}
