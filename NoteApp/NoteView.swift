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

    // 分类列表，与 ContentView 保持一致
    private let categories = ["Work", "Personal", "Ideas", "Shopping", "Uncategorized"]

    @State private var dragOrigin: CGPoint = .zero
    @State private var sizeOrigin: CGSize = .zero
    @State private var isFullScreen: Bool = false
    @FocusState private var isFocused: Bool

    private let minSize: CGFloat = 120
    private let handleSize: CGFloat = 24
    private let spacing: CGFloat = 8

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 笔记背景
            Rectangle()
                .fill(note.colour)
                .cornerRadius(8)
                .shadow(radius: 2)

            // 分类下拉菜单
            Menu {
                ForEach(categories, id: \.self) { cat in
                    Button(cat) { note.category = cat }
                }
            } label: {
                Text(note.category)
                    .font(.caption2).bold()
                    .padding(4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
            .offset(x: handleSize + spacing, y: spacing)

            // 文本编辑或显示
            Group {
                if note.isEditing {
                    TextEditor(text: $note.text)
                        .padding(8)
                        .focused($isFocused)
                        .onAppear { DispatchQueue.main.async { isFocused = true } }
                    
                    VoiceMemoControls(note: $note)
                        .padding(8)


                } else {
                    Text(note.text.isEmpty ? "New Note" : note.text)
                        .padding(8)
                        .onTapGesture { note.isEditing = true }
                }
            }
            
            
            .frame(width: note.size.width, height: note.size.height)
            
            // 删除按钮
            Button(action: { onDelete(note.id) }) {
                Image(systemName: "xmark")
                    .foregroundStyle(.black)
            }
            .frame(width: handleSize, height: handleSize)
            .offset(x: note.size.width - handleSize, y: 0)

            // 全屏切换按钮
            Button(action: { withAnimation(.easeInOut) { isFullScreen = true } }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .frame(width: handleSize, height: handleSize)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
            .offset(x: note.size.width - handleSize, y: note.size.height - handleSize)
            .foregroundStyle(.black)
        }
        .frame(width: note.size.width, height: note.size.height)
        .offset(x: note.position.x, y: note.position.y)
        // 使用高优先级手势，确保无延迟跟手
        .highPriorityGesture(dragGesture)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: note.position)
        .onChange(of: isFocused) { if !isFocused { note.isEditing = false } }
        .fullScreenCover(isPresented: $isFullScreen) {
            GeometryReader { fullGeo in
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    let maxSide = min(fullGeo.size.width, fullGeo.size.height) * 0.9
                    ZStack(alignment: .topTrailing) {
                        ScrollView {
                            Text(note.text.isEmpty ? "New Note" : note.text)
                                .padding()
                                .foregroundColor(.primary)
                        }
                        .frame(width: maxSide, height: maxSide)
                        .background(note.colour)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .transition(.scale)

                        Button(action: { withAnimation(.easeInOut) { isFullScreen = false } }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .padding(12)
                                .foregroundColor(.white)
                        }
                        .offset(x: -8, y: 8)
                    }
                    .frame(width: maxSide, height: maxSide)
                    .position(x: fullGeo.size.width / 2, y: fullGeo.size.height / 2)
                }
            }
        }
    }

    // 拖拽手势：禁用动画，实时更新位置
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
                withAnimation(.none) {
                    note.position = CGPoint(x: newX, y: newY)
                }
            }
            .onEnded { _ in
                dragOrigin = .zero
                // 拖拽结束后，应用格式化排列并添加动画
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                    onMoveEnd(note.id)
                }
            }
    }

    // 缩放手势
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

    // 辅助：范围限制
    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }
}
