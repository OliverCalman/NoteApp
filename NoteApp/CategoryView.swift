//
//  CategoryView.swift
//  NoteApp
//
//  Created by yuchen on 10/5/2025.
//

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
                    ForEach(notes) { note in
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(note.colour)
                                .cornerRadius(8)
                                .frame(width: side, height: side)
                            Text(note.text.isEmpty ? "New Note" : note.text)
                                .padding(8)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, verticalSpacing)
            }
            .navigationTitle(category)
        }
    }
}
