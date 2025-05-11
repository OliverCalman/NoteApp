// ComposePostView.swift
import SwiftUI

struct ComposePostView: View {
    @Binding var isPresented: Bool
    @State private var content: String
    @State private var selectedCategory: String
    @State private var selectedTags: Set<String>
    var categories: [String]
    var availableTags: [String]
    var onSend: (String, String, [String]) -> Void

    init(
        isPresented: Binding<Bool>,
        categories: [String],
        availableTags: [String],
        initialContent: String? = nil,
        initialCategory: String? = nil,
        initialTags: [String]? = nil,
        onSend: @escaping (String, String, [String]) -> Void
    ) {
        self._isPresented = isPresented
        self.categories = categories
        self.availableTags = availableTags
        self.onSend = onSend
        self._content = State(initialValue: initialContent ?? "")
        self._selectedCategory = State(initialValue: initialCategory ?? categories.first!)
        self._selectedTags = State(initialValue: Set(initialTags ?? []))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("Tags")) {
                    ForEach(availableTags, id: \.self) { tag in
                        Toggle(tag, isOn: Binding(
                            get: { selectedTags.contains(tag) },
                            set: { on in
                                if on { selectedTags.insert(tag) }
                                else { selectedTags.remove(tag) }
                            }
                        ))
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSend(trimmed, selectedCategory, Array(selectedTags))
                        isPresented = false
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
