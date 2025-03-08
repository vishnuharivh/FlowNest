//
//  Theme.swift
//  FlowNest
//
//  Created by Vishnu Hari on 3/4/25.
//

import Foundation
import SwiftUI

// MARK: - Theme Definition
struct Theme {
    // Main Colors
    let primary: Color
    let background: Color
    let surface: Color
    let text: Color
    let textSecondary: Color
    
    // Semantic Colors
    let success: Color
    let error: Color
    let warning: Color
    
    // Task Priority Colors
    let priorityHigh: Color
    let priorityMedium: Color
    let priorityLow: Color
    
    // Accent color (user customizable)
    var accent: Color
}

// MARK: - Predefined Themes
extension Theme {
    static let light = Theme(
        primary: Color(hex: "#000000"),
        background: Color(hex: "#FFFFFF"),
        surface: Color(hex: "#F5F5F5"),
        text: Color(hex: "#000000"),
        textSecondary: Color(hex: "#666666"),
        success: Color(hex: "#4CAF50"),
        error: Color(hex: "#F44336"),
        warning: Color(hex: "#FFC107"),
        priorityHigh: Color(hex: "#FF453A"), //Red
        priorityMedium: Color(hex: "#FF9F0A"), // Orange
        priorityLow: Color(hex: "#30D158"), // Green
        accent: Color.blue
    )
    
    static let dark = Theme(
        primary: Color(hex: "#FFFFFF"),
        background: Color(hex: "#121212"),
        surface: Color(hex: "#1E1E1E"),
        text: Color(hex: "#FFFFFF"),
        textSecondary: Color(hex: "#BBBBBB"),
        success: Color(hex: "#4CAF50"),
        error: Color(hex: "#F44336"),
        warning: Color(hex: "#FFC107"),
        priorityHigh: Color(hex: "#FF453A"),
        priorityMedium: Color(hex: "#FF9F0A"),
        priorityLow: Color(hex: "#30D158"),
        accent: Color.blue
    )
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


