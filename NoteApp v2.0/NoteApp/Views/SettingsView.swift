import SwiftUI

struct SettingsView: View {
    @ObservedObject var categoryManager: CategoryManager
    @State private var newCategory: String = ""

    var body: some View {
        Form {
            Section(header: Text("Add Category")) {
                HStack {
                    TextField("Category name", text: $newCategory)
                    Button("Add") {
                        categoryManager.add(name: newCategory)
                        newCategory = ""
                    }
                    .disabled(newCategory.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            Section(header: Text("Manage Categories")) {
                List {
                    ForEach(categoryManager.categories) { cat in
                        Text(cat.name)
                    }
                    .onDelete(perform: categoryManager.delete)
                    .onMove(perform: categoryManager.move)
                }
                .toolbar {
                    EditButton()
                }
            }
        }
        .navigationTitle("Categories")
    }
}
