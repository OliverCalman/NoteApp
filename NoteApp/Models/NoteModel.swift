//
//  NoteModel.swift
//  NoteApp
//
//  Created by Oliver Calman on 7/5/2025.
//

import SwiftUI

struct NoteModel: Identifiable {
    let id = UUID()
    var colour: Color
    var position: CGPoint
    var size: CGSize
    var text: String = ""
    var isEditing: Bool = false   
}
