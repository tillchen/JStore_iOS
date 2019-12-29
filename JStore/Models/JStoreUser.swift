//
//  User.swift
//  JStore
//
//  Created by Till Chen on 12/29/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import Foundation

public struct JStoreUser: Codable {
    let fullName: String
    let whatsApp: Bool
    let phoneNumber: String
    let email: String
    let creationDate: Date?
}
