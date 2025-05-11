//
//  CategoryModel.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

import Foundation

struct CategoryModel: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
