//
//  AudioMemoStore.swift
//  NoteApp
//
//  Created by Sameer Shaik on 11/5/2025.
//

import Foundation

/// Keeps track of which note-ID has which audio filename, persists via UserDefaults.
class AudioMemoStore {
    static let shared = AudioMemoStore()
    private let userDefaultsKey = "AudioMemoFilenames"
    private var memos: [String: String] = [:]  // [noteID.uuidString: filename]

    private init() {
        if let dict = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] {
            memos = dict
        }
    }

    private func save() {
        UserDefaults.standard.set(memos, forKey: userDefaultsKey)
    }

    /// Returns the file URL for a given note ID, or nil
    func url(for noteID: UUID) -> URL? {
        guard let fname = memos[noteID.uuidString] else { return nil }
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fname)
    }

    /// Associates (or removes, if filename=nil) an audio filename for that note ID.
    func set(filename: String?, for noteID: UUID) {
        if let f = filename {
            memos[noteID.uuidString] = f
        } else {
            memos.removeValue(forKey: noteID.uuidString)
        }
        save()
    }
}
