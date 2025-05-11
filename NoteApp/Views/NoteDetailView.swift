import SwiftUI

struct NoteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var content: String
    @State private var category: String
    let categories: [String]
    let noteID: UUID?
    let onSave: (NoteModel) -> Void

    init(
        note: NoteModel? = nil,
        categories: [String],
        onSave: @escaping (NoteModel) -> Void
    ) {
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
        _category = State(initialValue: note?.category ?? categories.first ?? "Uncategorized")
        self.categories = categories
        self.noteID = note?.id
        self.onSave = onSave
    }

    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Enter title", text: $title)
            }
            Section(header: Text("Content")) {
                TextEditor(text: $content)
                    .frame(minHeight: 200)
            }
            Section(header: Text("Category")) {
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .navigationTitle(noteID == nil ? "New Note" : "Edit Note")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let existingCreated = noteID == nil
                        ? Date()
                        : StorageManager.shared
                            .loadNotes()
                            .first { $0.id == noteID }?.createdAt
                            ?? Date()
                    let note = NoteModel(
                        id: noteID ?? UUID(),
                        title: title,
                        content: content,
                        category: category,
                        createdAt: existingCreated
                    )
                    onSave(note)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
