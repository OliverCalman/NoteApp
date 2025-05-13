//
//  NoteModel.swift
//  NoteApp
//
//  Updated: Added locationText field to support GPS-tagged notes

import SwiftUI
import CoreLocation

struct NoteModel: Identifiable, Codable {
    let id: UUID
    var colourHex: String
    var position: CGPoint
    var size: CGSize
    var text: String
    var isEditing: Bool
    var category: String
    var tags: [String]
    var locationText: String?
    
    // 🆕 地图支持字段
    var latitude: Double?
    var longitude: Double?
    
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    init(
        id: UUID = UUID(),
        colour: Color,
        position: CGPoint,
        size: CGSize,
        text: String = "",
        isEditing: Bool = false,
        category: String = "Uncategorized",
        tags: [String] = [],
        locationText: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.colourHex = colour.toHex() ?? "#FFFFFF"
        self.position = position
        self.size = size
        self.text = text
        self.isEditing = isEditing
        self.category = category
        self.tags = tags
        self.locationText = locationText
        self.latitude = latitude
        self.longitude = longitude
    }

    var colour: Color {
        Color(hex: colourHex) ?? .white
    }
}


// MARK: - Extensions for Color Codable Support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
