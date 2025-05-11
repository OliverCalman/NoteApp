//
//  CategoryView.swift
//  NoteApp
//
//  Created by yuchen on 10/5/2025.
//
// CategoryView.swift
import SwiftUI

struct CategoryView: View {
    let category: String
    let notes: [NoteModel]
    let horizontalPadding: CGFloat
    let verticalSpacing: CGFloat

    var body: some View {
        GeometryReader { geo in
            let side = (geo.size.width - 3 * horizontalPadding) / 2
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(side), spacing: horizontalPadding),
                        GridItem(.fixed(side), spacing: horizontalPadding)
                    ],
                    spacing: verticalSpacing
                ) {
                    ForEach(notes.filter { $0.category == category }) { note in
                        NoteView(note: note)
                            .frame(width: side, height: side)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, verticalSpacing)
            }
            .navigationTitle(category)
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var sampleNotes: [NoteModel] = [
        .init(title: "Buy milk", content: "2 liters of milk", category: "Shopping"),
        .init(title: "Meeting notes", content: "Discuss Q2 targets", category: "Work"),
        .init(title: "Ideas", content: "App redesign sketches", category: "Ideas"),
        .init(title: "Grocery list", content: "Eggs, bread", category: "Shopping")
    ]

    static var previews: some View {
        NavigationStack {
            CategoryView(
                category: "Shopping",
                notes: sampleNotes,
                horizontalPadding: 8,
                verticalSpacing: 8
            )
        }
    }
}
