import SwiftUI

struct ContentView: View {
    @State private var notes: [NoteModel] = [] {
        didSet { saveNotes() }
    }
    @State private var selectedCategory: String = "All"
    @State private var newNoteCategory: String = "Personal"
    @State private var searchText: String = ""
    @State private var scrollHeight: CGFloat = UIScreen.main.bounds.height
    @StateObject private var locationManager = LocationManager()

    @State private var selectedNote: NoteModel? = nil  // for map detail

    private let spacing: CGFloat = 8
    private let addButtonSize: CGFloat = 50
    private let userDefaultsKey = "SavedNotes"

    private let defaultCategories = [
        "All", "Work", "Study", "Personal", "Health", "Finance", "Shopping",
        "Entertainment", "Services", "Ideas", "Travel", "Uncategorized","Family"
    ]

    private var categories: [String] {
        defaultCategories
    }

    private var filteredNotes: [NoteModel] {
        notes.filter { note in
            (selectedCategory == "All" || note.category == selectedCategory) &&
            (searchText.isEmpty || note.text.localizedCaseInsensitiveContains(searchText))
        }
    }

    private var allTags: [String] {
        Array(Set(notes.flatMap { $0.tags })).sorted()
    }

    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search notes...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(6)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                    newNoteCategory = category == "All" ? "Personal" : category
                                }) {
                                    Text(category)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.4))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    }
                }
                .padding(.top, 10)
                .background(Color(.systemGray6))

                ZStack {
                    Color(.darkGray)
                        .ignoresSafeArea()
                        .onTapGesture { endEditing() }

                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .topLeading) {
                            Color.clear
                                .frame(height: scrollHeight)
                                .contentShape(Rectangle())
                                .onTapGesture { endEditing() }

                            ForEach(filteredNotes) { note in
                                NoteView(
                                    note: binding(for: note),
                                    parentSize: geo.size,
                                    safeTop: safeTop,
                                    onMoveEnd: { id in reorderAfterMove(id: id, in: geo.size, safeTop: safeTop) },
                                    onDelete: delete,
                                    allTags: allTags
                                )
                                .onTapGesture {
                                    selectedNote = note  // clic for full size view and mapkit
                                }
                                .zIndex(zIndex(for: note))
                            }
                        }
                    }

                    VStack {
                        Spacer()
                        Button(action: { addNote(in: geo.size, safeTop: safeTop) }) {
                            Image(systemName: "plus")
                                .foregroundStyle(.black)
                                .font(.system(size: 24))
                                .frame(width: addButtonSize, height: addButtonSize)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                        .padding(.bottom, spacing)
                    }
                }
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailView(note: note)
        }
        .onAppear(perform: loadNotes)
    }

    private func binding(for note: NoteModel) -> Binding<NoteModel> {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else {
            print("Error: Note not found")
            return .constant(note)
        }
        return $notes[idx]
    }

    //
    //  ContentView.swift - Updated: Two-column layout for new notes (preserve all existing behavior)

    private func addNote(in size: CGSize, safeTop: CGFloat) {
        let side = (size.width - 3 * spacing) / 2
        let topY = safeTop + spacing + 100
        var leftColumnY: CGFloat = topY
        var rightColumnY: CGFloat = topY

        for note in notes {
            if note.position.x < size.width / 2 {
                leftColumnY = max(leftColumnY, note.position.y + note.size.height + spacing)
            } else {
                rightColumnY = max(rightColumnY, note.position.y + note.size.height + spacing)
            }
        }

        let placeLeft = leftColumnY <= rightColumnY
        let xPos = placeLeft ? spacing : (spacing * 2 + side)
        let yPos = placeLeft ? leftColumnY : rightColumnY

        let newNote = NoteModel(
            colour: Color(hue: Double.random(in: 0...1), saturation: 0.3, brightness: 1),
            position: CGPoint(x: xPos, y: yPos),
            size: CGSize(width: side, height: side),
            category: newNoteCategory,
            locationText: locationManager.locationDescription,
            latitude: locationManager.coordinate?.latitude,
            longitude: locationManager.coordinate?.longitude
        )

        endEditing()
        withAnimation(.spring()) {
            notes.append(newNote)
            resolveOverlaps(in: size, safeTop: safeTop)
        }
    }


    private func delete(id: UUID) {
        notes.removeAll { $0.id == id }
        withAnimation(.spring()) {
            resolveOverlaps(in: UIScreen.main.bounds.size, safeTop: 100) // 你可以替换为 geo.size 和 safeTop 参数
        }
    }

    private func endEditing() {
        notes.indices.forEach { notes[$0].isEditing = false }
    }

    private func reorderAfterMove(id: UUID, in size: CGSize, safeTop: CGFloat) {
        notes.sort { a, b in
            if abs(a.position.y - b.position.y) > 1 {
                return a.position.y < b.position.y
            } else {
                return a.position.x < b.position.x
            }
        }
        withAnimation(.spring()) {
            resolveOverlaps(in: size, safeTop: safeTop)
        }
    }

    private func resolveOverlaps(in size: CGSize, safeTop: CGFloat) {
        let topY = safeTop + spacing
        notes.indices.forEach { i in
            notes[i].position.x = clamp(notes[i].position.x, min: spacing, max: size.width - notes[i].size.width - spacing)
            notes[i].position.y = max(notes[i].position.y, topY)
        }
        let leftColumn = notes.filter { $0.position.x < size.width/2 }.sorted { $0.position.y < $1.position.y }
        let rightColumn = notes.filter { $0.position.x >= size.width/2 }.sorted { $0.position.y < $1.position.y }
        var yLeft = topY
        for note in leftColumn {
            if let idx = notes.firstIndex(where: { $0.id == note.id }) {
                notes[idx].position.y = yLeft
                yLeft += notes[idx].size.height + spacing
            }
        }
        var yRight = topY
        for note in rightColumn {
            if let idx = notes.firstIndex(where: { $0.id == note.id }) {
                notes[idx].position.y = yRight
                yRight += notes[idx].size.height + spacing
            }
        }
        let maxY = notes.map { $0.position.y + $0.size.height }.max() ?? size.height
        scrollHeight = max(maxY + spacing, size.height)
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }

    private func zIndex(for note: NoteModel) -> Double {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else { return 0 }
        return Double(idx)
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving notes: \(error)")
        }
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                notes = try JSONDecoder().decode([NoteModel].self, from: data)
            } catch {
                print("Error loading notes: \(error)")
            }
        }
    }
}
