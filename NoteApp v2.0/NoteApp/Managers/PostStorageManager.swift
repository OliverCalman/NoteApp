//
//  PostStorageManager.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

import Foundation

final class PostStorageManager {
    static let shared = PostStorageManager()
    private let postsFile = "posts.json"
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func loadPosts() -> [PostModel] {
        let url = documentsDirectory.appendingPathComponent(postsFile)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([PostModel].self, from: data)
        } catch {
            print("Error loading posts: \(error)")
            return []
        }
    }

    func savePosts(_ posts: [PostModel]) {
        let url = documentsDirectory.appendingPathComponent(postsFile)
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: url, options: .atomicWrite)
        } catch {
            print("Error saving posts: \(error)")
        }
    }
}
