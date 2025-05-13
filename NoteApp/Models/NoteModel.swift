//
//  NoteModel.swift
//  NoteApp
//
//  Created by Oliver Calman on 7/5/2025.
//

import SwiftUI

struct NoteModel: Identifiable, Codable, Equatable {
    let id: UUID
    // 存储颜色的 HSB 分量
    var hue: Double
    var saturation: Double
    var brightness: Double

    var position: CGPoint
    var size: CGSize

    var text: String
    var category: String

    // 编辑状态，不参与持久化
    var isEditing: Bool = false

    // 计算属性，方便 SwiftUI 使用
    var colour: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    // 序列化键
    enum CodingKeys: String, CodingKey {
        case id, hue, saturation, brightness
        case positionX, positionY, width, height
        case text, category
    }

    // 解码
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        hue = try c.decode(Double.self, forKey: .hue)
        saturation = try c.decode(Double.self, forKey: .saturation)
        brightness = try c.decode(Double.self, forKey: .brightness)

        let x = try c.decode(CGFloat.self, forKey: .positionX)
        let y = try c.decode(CGFloat.self, forKey: .positionY)
        position = CGPoint(x: x, y: y)

        let w = try c.decode(CGFloat.self, forKey: .width)
        let h = try c.decode(CGFloat.self, forKey: .height)
        size = CGSize(width: w, height: h)

        text = try c.decode(String.self, forKey: .text)
        category = try c.decode(String.self, forKey: .category)
    }

    // 编码
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(hue, forKey: .hue)
        try c.encode(saturation, forKey: .saturation)
        try c.encode(brightness, forKey: .brightness)

        try c.encode(position.x, forKey: .positionX)
        try c.encode(position.y, forKey: .positionY)

        try c.encode(size.width, forKey: .width)
        try c.encode(size.height, forKey: .height)

        try c.encode(text, forKey: .text)
        try c.encode(category, forKey: .category)
    }

    // 方便初始化
    init(colour: Color,
         position: CGPoint,
         size: CGSize,
         text: String = "",
         category: String = "Uncategorized")
    {
        self.id = .init()
        // 提取 HSB
        let ui = UIColor(colour)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = Double(h); saturation = Double(s); brightness = Double(b)

        self.position = position
        self.size = size
        self.text = text
        self.category = category
    }
}
