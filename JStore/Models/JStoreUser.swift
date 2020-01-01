//
//  User.swift
//  JStore
//
//  Created by Till Chen on 12/29/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import Foundation

public struct JStoreUser: Codable {
    var fullName: String
    var whatsApp: Bool
    var phoneNumber: String
    var email: String
    var creationDate: Date?
    
    init(fullName: String, whatsApp: Bool, phoneNumber: String, email: String, creationDate: Date?) {
        self.fullName = fullName
        self.whatsApp = whatsApp
        self.phoneNumber = phoneNumber
        self.email = email
        self.creationDate = creationDate
    }
    
    init?(data: [String: Any]) {
        guard let fullName = data["fullName"] as? String,
            let whatsApp = data["whatsApp"] as? Bool,
            let phoneNumber = data["phoneNumber"] as? String,
            let email = data["email"] as? String else {
                return nil
        }
        self.fullName = fullName
        self.whatsApp = whatsApp
        self.phoneNumber = phoneNumber
        self.email = email
        self.creationDate = data["creationDate"] as? Date
    }
    
}
