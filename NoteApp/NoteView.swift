//
//  NoteView.swift
//  NoteApp
//
//  Created by Oliver Calman on 8/5/2025.
//
import SwiftUI

struct NoteView: View {
    @Binding var note: NoteModel
    let parentSize: CGSize
    let safeTop: CGFloat
    let onMoveEnd: (UUID) -> Void
    let onDelete: (UUID) -> Void

    //states for size and move functions
    @State private var dragOrigin: CGPoint = .zero
    @State private var sizeOrigin: CGSize = .zero

    //config size and buffer between notes
    private let minSize: CGFloat = 120
    private let handleSize: CGFloat = 24
    private let spacing: CGFloat = 8

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Rectangle()
                .fill(note.colour)
                .cornerRadius(8)
                .shadow(radius: 2)

            //Text area + edit view
            Group {
                if note.isEditing {
                    TextEditor(text: $note.text)
                        .padding(8)
                } else {
                    //default text
                    Text(note.text.isEmpty ? "New Note" : note.text)
                    //note.text :
                        .padding(8)
                        .onTapGesture { note.isEditing = true }
                }
            }
            .frame(width: note.size.width, height: note.size.height)

            //delete button
            Button(action: { onDelete(note.id) }) {
                Image(systemName: "xmark")
                    .foregroundStyle(.black)
            }
            .frame(width: handleSize, height: handleSize)
            .offset(x: note.size.width - handleSize, y: 0)

            //move 'handle'
            Image(systemName: "square.dashed")
                .frame(width: handleSize, height: handleSize)
                .offset(x: 0, y: 0)
                .gesture(dragGesture)
                .foregroundStyle(.black)

            // Resize handle
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

    //drag gesture updates position while moving, clamps to screen
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if dragOrigin == .zero { dragOrigin = note.position }
                let newX = clamp(dragOrigin.x + v.translation.width,
                                 min: spacing,
                                 max: parentSize.width - note.size.width - spacing)
                let newY = clamp(dragOrigin.y + v.translation.height,
                                 min: safeTop + spacing,
                                 max: .infinity)
                note.position = CGPoint(x: newX, y: newY)
            }
            .onEnded { _ in
                dragOrigin = .zero
                onMoveEnd(note.id)
            }
    }

    //resize updates size using drag gesture and clamps width
    private var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if sizeOrigin == .zero { sizeOrigin = note.size }
                let maxW = parentSize.width - note.position.x - spacing
                let newSide = clamp(sizeOrigin.width + v.translation.width,
                                    min: minSize,
                                    max: maxW)
                note.size = CGSize(width: newSide, height: newSide)
            }
            .onEnded { _ in sizeOrigin = .zero }
    }

    //clamp!
    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }
}
