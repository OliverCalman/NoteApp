//
//  NoteView.swift
//  NoteApp
//
//  Updated: Dragging now checks for proximity to other notes and avoids collision
//           Notes are positioned in two vertical columns at creation (managed by ContentView)

import SwiftUI

struct NoteView: View {
    @Binding var note: NoteModel
    let parentSize: CGSize
    let safeTop: CGFloat
    let onMoveEnd: (UUID) -> Void
    let onDelete: (UUID) -> Void
    var allTags: [String] = []
    var allNotes: [NoteModel] = []

    @State private var dragOrigin: CGPoint = .zero
    @State private var sizeOrigin: CGSize = .zero
    @State private var isEditingTags: Bool = false
    @State private var newTag: String = ""

    private let minSize: CGFloat = 120
    private let handleSize: CGFloat = 24
    private let spacing: CGFloat = 8
    private let safeDistance: CGFloat = 20

    private let categoryOptions = [
        "Work", "Study", "Personal", "Health", "Finance",
        "Shopping", "Entertainment", "Services", "Ideas", "Travel", "Uncategorized"
    ]

    private var suggestedTags: [String] {
        let input = newTag.lowercased()
        return allTags.filter { $0.lowercased().contains(input) && !note.tags.contains($0) && !input.isEmpty }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(note.colour)
                .cornerRadius(8)
                .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 4) {
                if note.isEditing {
                    VStack(alignment: .leading, spacing: 4) {
                        TextEditor(text: $note.text)
                            .padding(6)
                            .background(Color.white.opacity(0.3))

                        Picker("Category", selection: $note.category) {
                            ForEach(categoryOptions, id: \ .self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 6)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.text.isEmpty ? "New Note" : note.text)
                            .padding(6)
                            .foregroundColor(note.text.isEmpty ? .gray : .black)
                            .onTapGesture { note.isEditing = true }

                        if let location = note.locationText {
                            Text(location)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 6)
                        }
                    }
                }

                if !note.tags.isEmpty || isEditingTags {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ForEach(note.tags, id: \ .self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(.caption)
                                    Button(action: { deleteTag(tag) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                    }
                                }
                                .padding(4)
                                .background(Color.white.opacity(0.25))
                                .cornerRadius(6)
                            }
                            if isEditingTags {
                                TextField("+tag", text: $newTag)
                                    .font(.caption)
                                    .frame(width: 60)
                            }
                            Button(action: {
                                if !newTag.isEmpty { addTag() }
                                isEditingTags.toggle()
                            }) {
                                Image(systemName: isEditingTags ? "checkmark" : "tag")
                                    .font(.caption)
                            }
                        }

                        if isEditingTags && !suggestedTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(suggestedTags, id: \ .self) { tag in
                                        Button(action: {
                                            note.tags.append(tag)
                                            newTag = ""
                                        }) {
                                            Text(tag)
                                                .font(.caption2)
                                                .padding(5)
                                                .background(Color.blue.opacity(0.3))
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                                .padding(.leading, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
                }
            }
            .frame(width: note.size.width, height: note.size.height - handleSize)

            Button(action: { onDelete(note.id) }) {
                Image(systemName: "xmark")
                    .foregroundStyle(.black)
            }
            .frame(width: handleSize, height: handleSize)
            .offset(x: note.size.width - handleSize, y: 0)

            Image(systemName: "square.dashed")
                .frame(width: handleSize, height: handleSize)
                .offset(x: 0, y: 0)
                .gesture(dragGesture)
                .foregroundStyle(.black)

            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .frame(width: handleSize, height: handleSize)
                .offset(x: note.size.width - handleSize, y: note.size.height - handleSize)
                .gesture(resizeGesture)
                .foregroundStyle(.black)
        }
        .frame(width: note.size.width, height: note.size.height)
        .offset(x: note.position.x, y: note.position.y)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: note.position)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if dragOrigin == .zero { dragOrigin = note.position }
                let newX = clamp(dragOrigin.x + v.translation.width, min: spacing, max: parentSize.width - note.size.width - spacing)
                var newY = clamp(dragOrigin.y + v.translation.height, min: safeTop + spacing, max: parentSize.height - note.size.height - spacing)

                let noteRect = CGRect(origin: CGPoint(x: newX, y: newY), size: note.size)
                for other in allNotes where other.id != note.id {
                    let otherRect = CGRect(origin: other.position, size: other.size).insetBy(dx: -safeDistance, dy: -safeDistance)
                    if noteRect.intersects(otherRect) {
                        newY += safeDistance
                    }
                }

                note.position = CGPoint(x: newX, y: newY)
            }
            .onEnded { _ in
                dragOrigin = .zero
                onMoveEnd(note.id)
            }
    }

    private var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if sizeOrigin == .zero { sizeOrigin = note.size }
                let maxW = parentSize.width - note.position.x - spacing
                let maxH = parentSize.height - note.position.y - spacing
                let newWidth = clamp(sizeOrigin.width + v.translation.width, min: minSize, max: maxW)
                let newHeight = clamp(sizeOrigin.height + v.translation.height, min: minSize, max: maxH)
                note.size = CGSize(width: newWidth, height: newHeight)
            }
            .onEnded { _ in
                sizeOrigin = .zero
            }
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }

    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !note.tags.contains(trimmed) else { return }
        note.tags.append(trimmed)
        newTag = ""
    }

    private func deleteTag(_ tag: String) {
        note.tags.removeAll { $0 == tag }
    }
}
