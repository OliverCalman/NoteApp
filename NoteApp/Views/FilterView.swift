import SwiftUI

struct FilterView: View {
    @Binding var isPresented: Bool
    var categories: [String]
    var tags: [String]
    @Binding var selectedCategory: String
    @Binding var selectedTag: String

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Filter by Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("Filter by Tag")) {
                    Picker("Tag", selection: $selectedTag) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag.isEmpty ? "All" : tag)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Filter")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}
