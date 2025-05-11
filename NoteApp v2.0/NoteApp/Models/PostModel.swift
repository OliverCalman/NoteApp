//
//  PostModel.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

import Foundation

struct PostModel: Identifiable, Codable {
    let id: UUID
    let userId: String
    var content: String
    let latitude: Double
    let longitude: Double
    var locationName: String
    let createdAt: Date
    var category: String
    var tags: [String]

    init(
        id: UUID = UUID(),
        userId: String,
        content: String,
        latitude: Double,
        longitude: Double,
        locationName: String = "Sydney, NSW 2000",
        createdAt: Date = Date(),
        category: String = "Daily Life",
        tags: [String] = []
    ) {
        self.id = id
        self.userId = userId
        self.content = content
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.createdAt = createdAt
        self.category = category
        self.tags = tags
    }
}
