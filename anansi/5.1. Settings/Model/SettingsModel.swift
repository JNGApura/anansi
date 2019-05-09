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
    var structure = [SettingsRow]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Gets table data from json
                if let structure = json["structure"] as? [[String: Any]] {
                    self.structure = structure.map { SettingsRow(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return
        }
    }
}

// TableRow initialization
struct SettingsRow {
    
    var action: String?
    var icon: String?
    var title: String?
    var url: String?
    
    init(json: [String: Any]) {
        self.action = json["action"] as? String
        self.icon = json["icon"] as? String
        self.title = json["title"] as? String
        if let url = json["url"] as? String { // to be safe
            self.url = url
        }
    }
}
