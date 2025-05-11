import Foundation

struct NoteModel: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var category: String
    let createdAt: Date

    init(id: UUID = UUID(),
         title: String,
         content: String,
         category: String,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = createdAt
    }
}
