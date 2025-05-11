import Foundation

final class StorageManager {
    static let shared = StorageManager()
    private init() {}

    private let notesFile = "notes.json"
    private let categoriesFile = "categories.json"

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    // MARK: - Notes
    func saveNotes(_ notes: [NoteModel]) {
        let url = documentsDirectory.appendingPathComponent(notesFile)
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: url, options: .atomicWrite)
        } catch {
            print("Error saving notes: \(error)")
        }
    }

    func loadNotes() -> [NoteModel] {
        let url = documentsDirectory.appendingPathComponent(notesFile)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([NoteModel].self, from: data)
        } catch {
            print("Error loading notes: \(error)")
            return []
        }
    }

    // MARK: - Categories
    func saveCategories(_ categories: [CategoryModel]) {
        let url = documentsDirectory.appendingPathComponent(categoriesFile)
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: url, options: .atomicWrite)
        } catch {
            print("Error saving categories: \(error)")
        }
    }

    func loadCategories() -> [CategoryModel] {
        let url = documentsDirectory.appendingPathComponent(categoriesFile)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return ["All", "Uncategorized", "Work", "Personal", "Ideas", "Shopping"].map {
                CategoryModel(name: $0)
            }
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([CategoryModel].self, from: data)
        } catch {
            print("Error loading categories: \(error)")
            return []
        }
    }
}
