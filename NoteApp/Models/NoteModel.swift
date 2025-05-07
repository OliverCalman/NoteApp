//
//  NoteModel.swift
//  NoteApp
//
//  Created by Oliver Calman on 7/5/2025.
//

import SwiftUI

struct NoteModel: Identifiable {
    let id = UUID()
    let colour: Color
    let position: CGPoint
    let width: CGFloat
    let height: CGFloat
}
