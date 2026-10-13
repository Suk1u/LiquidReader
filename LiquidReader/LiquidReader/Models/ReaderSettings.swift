//
//  ReaderSettings.swift
//  LiquidReader
//
//  阅读器个性化排版与显示设置
//

import SwiftUI
import Observation

public enum PageTurnMode: String, CaseIterable, Identifiable, Codable {
    case scroll = "连续滚动"
    case paging = "仿真翻页"
    
    public var id: String { rawValue }
}

@Observable
public final class ReaderSettings {
    public var fontSize: CGFloat = 19.0
    public var lineSpacing: CGFloat = 8.0
    public var horizontalPadding: CGFloat = 20.0
    public var theme: ReaderTheme = .paper
    public var fontDesign: ReaderFontDesign = .serif
    public var pageTurnMode: PageTurnMode = .scroll
    public var useLiquidGlassToolbar: Bool = true
    
    public init() {}
    
    public func resetToDefaults() {
        fontSize = 19.0
        lineSpacing = 8.0
        horizontalPadding = 20.0
        theme = .paper
        fontDesign = .serif
        pageTurnMode = .scroll
        useLiquidGlassToolbar = true
    }
}
