// NoteView.swift
import SwiftUI

struct NoteView: View {
    let note: NoteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
            Text(note.content)
                .font(.subheadline)
                .lineLimit(2)
            HStack {
                Text(note.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(note.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color(.black).opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(note: NoteModel(
            title: "Sample Note",
            content: "This is a preview of a note content that might be a bit longer.",
            category: "Ideas"
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
