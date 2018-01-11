//
//  SettingsModel.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation

// Extracts the content from the .json file, and represents it as Data
public func dataFromFile(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return nil
}

// Settings Model
class Settings {
    var table = [TableRow]()
    
    init?(data: Data) {
        do {
            // I use standard Swift JSONSerialization to keep the project simple
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["data"] as? [String: Any] {
                
                // Gets row data from JSON and maps into the table object
                if let table = body["table"] as? [[String: Any]] {
                    self.table = table.map { TableRow(json: $0)}
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
}

// Row type initialization
class TableRow {
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
        if let url = json["url"] as? String {
            self.url = url
        }
    }
}
enum RowType {
    case normal
    case section
}
