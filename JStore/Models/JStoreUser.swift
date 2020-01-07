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
}
