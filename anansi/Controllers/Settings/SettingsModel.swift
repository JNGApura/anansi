//
//  SettingsModel.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation

// Settings Model
struct Settings {
    var structure = [TableRow]()
    var about = [AboutPage]()
    
    init?(data: [String: AnyObject]?) {
        guard let body = data else { return }
        
        // Gets data and maps into the structure object
        if let structure = body["structure"] as? [[String: Any]] {
            self.structure = structure.map { TableRow(json: $0)}
        }
        
        // Gets data and maps into the about object
        if let about = body["about"] as? [[String: Any]] {
            self.about = about.map { AboutPage(json: $0)}
        }
    }
}

// TableRow initialization
struct TableRow {
    var ofType: RowType
    var value: String?
    var iconUrl: String?
    var action: String?
    var url: String?
    
    init(json: [String: Any]) {
        self.ofType = (json["ofType"] as? String == "normal") ? .normal : .section
        self.value = json["value"] as? String
        self.iconUrl = json["iconUrl"] as? String
        self.action = json["action"] as? String
        if let url = json["url"] as? String { // to be safe
            self.url = url
        }
    }
}
enum RowType {
    case normal
    case section
}

// AboutSection initialization
struct AboutPage {
    var id: String?
    var section: [AboutPageSection]?
    
    init(json: [String : Any]) {
        self.id = json["id"] as? String
        if let section = json["section"] as? [[String: Any]] {
            self.section = section.map {AboutPageSection (json: $0)}
        }
    }
}

struct AboutPageSection {
    var title: String?
    var text: String?
    
    init(json: [String: Any]){
        self.title = json["title"] as? String
        self.text = json["text"] as? String
    }
}
