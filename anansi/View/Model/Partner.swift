//
//  Partner.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

enum partnerInfoType: String {
    case id = "id"
    case type = "type"
    case profileImageURL = "profileImageURL"
    case name = "name"
    case field = "field"
    case location = "location"
    case about = "bio"
    case website = "website"
    case linkedin = "linkedin"
    case employees = "employees"
}

class Partner: NSObject {
    
    // MARK: Properties
    private var id: String!
    private var type: String!
    private var profileImageURL: String!
    private var name: String!
    private var field: String!
    private var location: String!
    private var about: String!
    private var website: String!
    private var linkedin: String!
    private var employees: [String]!
    
    // MARK: Initialization
    override init () {
        super.init()
    }
    
    func set(dictionary: [String: Any], id: String) {
        
        setValue(value: id, for: partnerInfoType.id)

        for item in dictionary {
            
            if let field = partnerInfoType(rawValue: item.key) {
                setValue(value: item.value, for: field)
            }
        }
    }
    
    // Sets value for field
    func setValue(value: Any, for field: partnerInfoType) {
        
        switch field {
        case .id:
            if let id = value as? String { self.id = id }
        case .type:
            if let type = value as? String { self.type = type }
        case .name:
            if let name = value as? String { self.name = name }
        case .field:
            if let field = value as? String { self.field = field}
        case .location:
            if let location = value as? String { self.location = location}
        case .profileImageURL:
            if let profileImageURL = value as? String { self.profileImageURL = profileImageURL }
        case .about:
            if let about = value as? String { self.about = about }
        case .website:
            if let website = value as? String { self.website = website }
        case .linkedin:
            if let linkedin = value as? String { self.linkedin = linkedin }
        case .employees:
            if let employees = value as? [String] { self.employees = employees }
        }
    }
    
    // Gets value for field
    func getValue(forField field: partnerInfoType) -> Any {
        
        switch field {
        case .id: return id
        case .type: return type
        case .name: return name
        case .field: return self.field
        case .location: return location
        case .profileImageURL: return profileImageURL
        case .about: return about
        case .website: return website
        case .linkedin: return linkedin
        case .employees: return employees
        }
    }
    
    // Gets label for specific field / property
    func label(forField field: partnerInfoType) -> String {
        
        switch field {
        case .id: return "Identification"
        case .type: return "Type of partnership"
        case .name: return "Name"
        case .field: return "Field"
        case .location: return "Location"
        case .profileImageURL: return "Icon / Brand"
        case .about: return "About:"
        case .website: return "Website"
        case .linkedin: return "Linkedin"
        case .employees: return "Get in touch with"
        }
    }
    
    func reset() {
        self.id = nil
        self.name = nil
        self.field = nil
        self.location = nil
        self.type = nil
        self.profileImageURL = nil
        self.about = nil
        self.website = nil
        self.linkedin = nil
        self.employees = nil
    }
}
