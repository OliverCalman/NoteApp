//
//  ContentView.swift
//  NoteApp
//
//  Created by Oliver Calman on 7/5/2025.
//

import SwiftUI

struct ContentView: View {

    // MARK: — Configuration —
    private let categories = ["All", "Uncategorized", "Work", "Personal", "Ideas", "Shopping"]
    private let categoryBarHeight: CGFloat = 50
    private let horizontalPadding: CGFloat = 8
    private let verticalSpacing: CGFloat = 4
    private let addButtonSize: CGFloat = 50
    private let userDefaultsKey = "SavedNotes_v1"

    @State private var selectedCategory = "All"
    @State private var notes: [NoteModel] = []
    @State private var scrollHeight: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let safeTop = geo.safeAreaInsets.top + categoryBarHeight + verticalSpacing

                ZStack {
                    // Background tap ends editing
                    Color(.darkGray)
                        .ignoresSafeArea()
                        .onTapGesture { endEditing() }

                    VStack(spacing: 0) {
                        // Category bar
                        categoryBar

                        // Draggable "All" notes grid
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                Color.clear
                                    .frame(height: scrollHeight)
                                    .contentShape(Rectangle())
                                    .onTapGesture { endEditing() }

                                ForEach(notes) { note in
                                    NoteView(
                                        note: binding(for: note),
                                        parentSize: geo.size,
                                        safeTop: safeTop,
                                        onMoveEnd: { _ in reorderAfterMove(in: geo.size, safeTop: safeTop) },
                                        onDelete: delete
                                    )
                                    .zIndex(zIndex(for: note))
                                }
                            }
                        }
                    }

                    // Add button
                    VStack {
                        Spacer()
                        Button {
                            addNote(in: geo.size, safeTop: safeTop)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .frame(width: addButtonSize, height: addButtonSize)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                                .foregroundColor(.black)
                        }
                        .padding(.bottom, horizontalPadding)
                    }
                }
            }
            .navigationTitle("Notes")
            .onAppear(perform: loadNotes)
            .onChange(of: notes) { _, _ in saveNotes() }
        }
    }

    // MARK: — Category Bar —
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { cat in
                    CategoryButton(
                        cat: cat,
                        selectedCategory: $selectedCategory,
                        notes: notes,
                        horizontalPadding: horizontalPadding,
                        verticalSpacing: verticalSpacing
                    )
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(height: categoryBarHeight)
        .background(Color(.systemGray5))
    }

    // MARK: — Helpers —


    private func binding(for note: NoteModel) -> Binding<NoteModel> {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else {
            fatalError("Note not found")
        }
        return $notes[idx]
    }

    private func delete(id: UUID) {
        // Remove the selected note, then fill its position
        if let idx = notes.firstIndex(where: { $0.id == id }) {
            let removedPos = notes[idx].position
            notes.remove(at: idx)
            if idx < notes.count {
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                    notes[idx].position = removedPos
                }
            }
        }
    }

    private func endEditing() {
        for i in notes.indices { notes[i].isEditing = false }
    }

    private func addNote(in size: CGSize, safeTop: CGFloat) {
        let side = (size.width - 3 * horizontalPadding) / 2
        let step = side + horizontalPadding
        let cols = 2
        var placed = false
        var pos = CGPoint.zero

        for row in 0..<Int(ceil((size.height - safeTop) / step)) {
            let y = safeTop + CGFloat(row) * step
            for col in 0..<cols {
                let x = horizontalPadding + CGFloat(col) * step
                let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: side, height: side))
                if !notes.contains(where: { CGRect(origin: $0.position, size: $0.size).intersects(rect) }) {
                    pos = CGPoint(x: x, y: y)
                    placed = true
                    break
                }
            }
            if placed { break }
        }
        if !placed {
            let maxY = notes.map { $0.position.y + $0.size.height }.max() ?? safeTop
            pos = CGPoint(x: horizontalPadding, y: maxY + horizontalPadding)
        }

        let cat = selectedCategory == "All" ? "Uncategorized" : selectedCategory
        let newNote = NoteModel(colour: Color(hue: Double.random(in: 0...1), saturation: 0.3, brightness: 1),
                                 position: pos,
                                 size: CGSize(width: side, height: side),
                                 text: "", category: cat)
        endEditing()
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
=======
    //position behaviour. Adds a new note in the first available spot or pushes others down
    private func addNote(in size: CGSize, safeTop: CGFloat) {
        let side = (size.width - 3*spacing) / 2
        let topY = safeTop + spacing
        //compute X slots and select first free
        var xs = [spacing]
        notes.filter { abs($0.position.y - topY) < 1 }.forEach {
            xs.append($0.position.x + $0.size.width + spacing)
        }
        xs.sort()
        let xPos = xs.first(where: { x in
            x + side <= size.width - spacing &&
            !notes.contains(where: { CGRect(origin: CGPoint(x: x, y: topY), size: CGSize(width: side, height: side)).intersects(CGRect(origin: $0.position, size: $0.size)) })
        }) ?? spacing
        //push down if needed
        if xPos == spacing && notes.contains(where: { $0.position.y == topY && $0.position.x == spacing }) {
            notes.indices.forEach { notes[$0].position.y += side + spacing }
        }
        //append new note
        let newNote = NoteModel(colour: Color(hue: Double.random(in: 0...1), saturation: 0.3, brightness: 1),
                                position: CGPoint(x: xPos, y: topY),
                                size: CGSize(width: side, height: side))
        endEditing()
        withAnimation(.spring()) {

            notes.append(newNote)
            resolveOverlaps(in: size, safeTop: safeTop)
        }
    }


    private func reorderAfterMove(in size: CGSize, safeTop: CGFloat) {

        notes.sort { a, b in
            if abs(a.position.y - b.position.y) > 1 {
                return a.position.y < b.position.y
            } else {
                return a.position.x < b.position.x
            }
        }
        let side = (size.width - 3 * horizontalPadding) / 2
        let step = side + horizontalPadding
        for (idx, _) in notes.enumerated() {
            let row = idx / 2, col = idx % 2
            notes[idx].position = CGPoint(x: horizontalPadding + CGFloat(col) * step,
                                          y: safeTop + CGFloat(row) * step)
        }
        let rows = (notes.count + 1) / 2
        scrollHeight = max(size.height, safeTop + CGFloat(rows) * step)
    }

    private func resolveOverlaps(in size: CGSize, safeTop: CGFloat) {
        let minY = safeTop
        for i in notes.indices {
            notes[i].position.x = clamp(notes[i].position.x,
                                        min: horizontalPadding,
                                        max: size.width - notes[i].size.width - horizontalPadding)
            if notes[i].position.y < minY {
                notes[i].position.y = minY
            }
        }
        for i in notes.indices {
            let a = CGRect(origin: notes[i].position, size: notes[i].size)
            for j in notes.indices where i != j {
                let b = CGRect(origin: notes[j].position, size: notes[j].size)
                if a.intersects(b) {
                    notes[j].position.y = a.maxY + horizontalPadding
                }
            }
        }
        let maxY = notes.map { $0.position.y + $0.size.height }.max() ?? UIScreen.main.bounds.height
        scrollHeight = max(maxY + horizontalPadding, UIScreen.main.bounds.height)
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }

    private func zIndex(for note: NoteModel) -> Double {
        Double(notes.firstIndex(where: { $0.id == note.id }) ?? 0)
    }

    private func saveNotes() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let stored = try? JSONDecoder().decode([NoteModel].self, from: data) else { return }
        notes = stored
    }
}

// MARK: — CategoryButton Subview —

private struct CategoryButton: View {
    let cat: String
    @Binding var selectedCategory: String
    let notes: [NoteModel]
    let horizontalPadding: CGFloat
    let verticalSpacing: CGFloat

    var body: some View {
        let isSelected = selectedCategory == cat
        if cat == "All" {
            Button(action: { selectedCategory = "All" }) {
                Text("All")
                    .font(.subheadline).bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.4)))
                    .foregroundColor(isSelected ? .white : .black)
            }
        } else {
            let filtered = notes.filter { $0.category == cat }
            NavigationLink(destination:
                CategoryView(
                    category: cat,
                    notes: filtered,
                    horizontalPadding: horizontalPadding,
                    verticalSpacing: verticalSpacing
                )
            ) {
                Text(cat)
                    .font(.subheadline).bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.4)))
                    .foregroundColor(isSelected ? .white : .black)
            }
        }
    }
}
