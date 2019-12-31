//
//  Post.swift
//  JStore
//
//  Created by Till Chen on 12/31/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import Foundation

public struct Post: Codable {
    let postId: String
    let sold: Bool
    let ownerId: String // email address
    let ownerName: String
    let whatsApp: Bool
    let phoneNumber: String
    let title: String
    let category: String
    let condition: String
    let description: String
    let imageUrl: String
    let price: Double
    let paymentOptions: [String]
    let creationDate: Date?
    let soldDate: Date?
}
