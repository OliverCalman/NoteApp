//
//  ContentView.swift
//  NoteApp
//
//  Created by Oliver Calman on 7/5/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var notes: [NoteModel] = []
    @State private var scrollHeight: CGFloat = UIScreen.main.bounds.height

    private let spacing: CGFloat = 8
    private let addButtonSize: CGFloat = 50

    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            ZStack {
                //background colour and func - close open edit feature on tap
                Color(.darkGray)
                    .ignoresSafeArea()
                    .onTapGesture { endEditing() }

                //zstack containing notes. Position any other UI components outside this stack
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        Color.clear
                            .frame(height: scrollHeight)
                            .contentShape(Rectangle())
                            .onTapGesture { endEditing() }

                        //array of notes
                        ForEach(notes) { note in
                            NoteView(
                                note: binding(for: note),
                                parentSize: geo.size,
                                safeTop: safeTop,
                                onMoveEnd: { id in reorderAfterMove(id: id, in: geo.size, safeTop: safeTop) },
                                onDelete: delete
                            )
                            .zIndex(zIndex(for: note))
                        }
                    }
                }

                //create new notes
                VStack { Spacer()
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


    //locate the note being moved, sized, or edited
    private func binding(for note: NoteModel) -> Binding<NoteModel> {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else {
            fatalError("Note not found")
        }
        return $notes[idx]
    }

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

    //delete note function
    private func delete(id: UUID) {
        notes.removeAll { $0.id == id }
    }

    //set isEditing to false - used when tapping ext. zstack
    private func endEditing() {
        notes.indices.forEach { notes[$0].isEditing = false }
    }

    //updates array when finished moving
    private func reorderAfterMove(id: UUID, in size: CGSize, safeTop: CGFloat) {
        //sort notes by position (left-right-down)
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

    //clamps and stops overlap
    private func resolveOverlaps(in size: CGSize, safeTop: CGFloat) {
        let topY = safeTop + spacing
        
        notes.indices.forEach { i in
            notes[i].position.x = clamp(notes[i].position.x,
                                        min: spacing,
                                        max: size.width - notes[i].size.width - spacing)
            notes[i].position.y = max(notes[i].position.y, topY)
        }
        //overlaps
        notes.indices.forEach { i in
            let rectA = CGRect(origin: notes[i].position, size: notes[i].size)
            notes.indices.forEach { j in
                if i != j {
                    let rectB = CGRect(origin: notes[j].position, size: notes[j].size)
                    if rectA.intersects(rectB) {
                        notes[j].position.y = rectA.maxY + spacing
                    }
                }
            }
        }
        //set responsive scroll height
        let maxY = notes.map { $0.position.y + $0.size.height }.max() ?? size.height
        scrollHeight = max(maxY + spacing, size.height)
    }

    //clamp method (can be merged to noteview)
    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }

    //set new notes at top of view
    private func zIndex(for note: NoteModel) -> Double {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else { return 0 }
        return Double(idx)
    }
}

#Preview {
    ContentView()
}
