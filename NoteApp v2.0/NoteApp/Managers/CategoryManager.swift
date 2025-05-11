//
//  CategoryManager.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

import SwiftUI

final class CategoryManager: ObservableObject {
    @Published var categories: [CategoryModel] = []

    init() {
        categories = StorageManager.shared.loadCategories()
    }

    func add(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let new = CategoryModel(name: trimmed)
        categories.append(new)
        save()
    }

    func delete(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private func save() {
        StorageManager.shared.saveCategories(categories)
    }
}
