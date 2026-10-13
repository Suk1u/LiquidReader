//
//  Theme.swift
//  LiquidReader
//
//  阅读器色彩与排版主题系统
//

import SwiftUI

public enum ReaderTheme: String, CaseIterable, Identifiable, Codable {
    case paper = "羊皮纸"
    case system = "纯白"
    case sepia = "复古"
    case twilight = "暮色"
    case oled = "极黑"
    
    public var id: String { rawValue }
    
    public var backgroundColor: Color {
        switch self {
        case .paper:
            return Color(red: 0.96, green: 0.94, blue: 0.89)
        case .system:
            return Color(red: 0.99, green: 0.99, blue: 0.99)
        case .sepia:
            return Color(red: 0.92, green: 0.87, blue: 0.79)
        case .twilight:
            return Color(red: 0.16, green: 0.18, blue: 0.22)
        case .oled:
            return Color.black
        }
    }
    
    public var textColor: Color {
        switch self {
        case .paper, .system, .sepia:
            return Color(red: 0.18, green: 0.18, blue: 0.18)
        case .twilight:
            return Color(red: 0.88, green: 0.90, blue: 0.94)
        case .oled:
            return Color(red: 0.82, green: 0.82, blue: 0.82)
        }
    }
    
    public var secondaryTextColor: Color {
        switch self {
        case .paper, .system, .sepia:
            return Color.black.opacity(0.55)
        case .twilight, .oled:
            return Color.white.opacity(0.55)
        }
    }
    
    public var ambientGradients: [Color] {
        switch self {
        case .paper:
            return [Color(red: 0.96, green: 0.92, blue: 0.84), Color(red: 0.93, green: 0.89, blue: 0.82)]
        case .system:
            return [Color.white, Color(red: 0.95, green: 0.96, blue: 0.98)]
        case .sepia:
            return [Color(red: 0.91, green: 0.84, blue: 0.74), Color(red: 0.87, green: 0.79, blue: 0.69)]
        case .twilight:
            return [Color(red: 0.12, green: 0.14, blue: 0.19), Color(red: 0.18, green: 0.21, blue: 0.28)]
        case .oled:
            return [Color.black, Color(white: 0.05)]
        }
    }
    
    public var isDark: Bool {
        self == .twilight || self == .oled
    }
}

public enum ReaderFontDesign: String, CaseIterable, Identifiable, Codable {
    case serif = "宋体 / 衬线"
    case standard = "黑体 / 标准"
    case rounded = "圆体 / 柔和"
    case monospaced = "等宽"
    
    public var id: String { rawValue }
    
    public var fontDesign: Font.Design {
        switch self {
        case .serif: return .serif
        case .standard: return .default
        case .rounded: return .rounded
        case .monospaced: return .monospaced
        }
    }
}
