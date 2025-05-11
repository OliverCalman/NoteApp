//
//  PostDetailView.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

// PostDetailView.swift
import SwiftUI

struct PostDetailView: View {
    let post: PostModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.content)
                .font(.title2)
            Text(post.locationName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Divider()
            HStack {
                Text("By: \(post.userId)")
                Spacer()
                Text(post.createdAt, style: .date)
                Text(post.createdAt, style: .time)
            }
            .font(.caption)
            Spacer()
        }
        .padding()
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
