//
//  Post.swift
//  JStore
//
//  Created by Till Chen on 12/31/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import Foundation

public struct Post: Codable { // TODO: Add the init for data: [String: Any]
    var postId: String
    var sold: Bool
    var ownerId: String // email address
    var ownerName: String
    var whatsApp: Bool
    var phoneNumber: String
    var title: String
    var category: String
    var condition: String
    var description: String
    var imageUrl: String
    var price: Double
    var paymentOptions: [String]
    var creationDate: Date?
    var soldDate: Date?
}
