//
//  ReaderSettingsSheetView.swift
//  LiquidReader
//
//  排版与视觉设置面板：支持 Liquid Glass 拟态、原生分段控制与全量无障碍
//

import SwiftUI

public struct ReaderSettingsSheetView: View {
    @Bindable var settings: ReaderSettings
    @Environment(\.dismiss) private var dismiss
    
    public init(settings: ReaderSettings) {
        self.settings = settings
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // 主题色板选择
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ReaderTheme.allCases) { theme in
                                Button {
                                    settings.theme = theme
                                } label: {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(theme.backgroundColor)
                                                .frame(width: 44, height: 44)
                                                .overlay {
                                                    Circle()
                                                        .strokeBorder(
                                                            settings.theme == theme ? Color.accentColor : Color.primary.opacity(0.15),
                                                            lineWidth: settings.theme == theme ? 2.5 : 1.0
                                                        )
                                                }
                                            
                                            if settings.theme == theme {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(theme.textColor)
                                            }
                                        }
                                        
                                        Text(theme.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(settings.theme == theme ? .primary : .secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("主题风格: \(theme.rawValue)")
                                .accessibilityAddTraits(settings.theme == theme ? [.isSelected] : [])
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("纸张质感与主题")
                }
                
                // 字体字形
                Section {
                    Picker("字体风格", selection: $settings.fontDesign) {
                        ForEach(ReaderFontDesign.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("字体字形选择")
                } header: {
                    Text("排版字形")
                }
                
                // 字号调节
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("A")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            
                            Slider(value: $settings.fontSize, in: 14...32, step: 1)
                                .accessibilityLabel("字号大小")
                                .accessibilityValue("\(Int(settings.fontSize)) 磅")
                            
                            Text("A")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("当前字号: \(Int(settings.fontSize)) pt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 行间距
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                                .foregroundStyle(.secondary)
                            
                            Slider(value: $settings.lineSpacing, in: 4...24, step: 2)
                                .accessibilityLabel("行间距")
                                .accessibilityValue("\(Int(settings.lineSpacing)) 点")
                        }
                        
                        Text("行距倍率: \(Int(settings.lineSpacing)) pt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("字号与行距")
                }
                
                // 翻页模式与流体工具栏
                Section {
                    Picker("翻页逻辑", selection: $settings.pageTurnMode) {
                        ForEach(PageTurnMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("阅读翻页逻辑")
                    
                    Toggle("流体玻璃悬浮工具条", isOn: $settings.useLiquidGlassToolbar)
                        .accessibilityLabel("启用流体玻璃悬浮工具条开关")
                } header: {
                    Text("交互与材质")
                }
                
                // 重置按钮
                Section {
                    Button(role: .destructive) {
                        withAnimation {
                            settings.resetToDefaults()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("恢复默认排版设置")
                            Spacer()
                        }
                    }
                    .accessibilityLabel("恢复默认排版设置")
                }
            }
            .scrollContentBackground(.hidden)
            .background(AmbientLiquidMesh(tintColor: .indigo))
            .navigationTitle("排版偏好")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("关闭排版设置")
                }
            }
        }
    }
}

#Preview {
    ReaderSettingsSheetView(settings: ReaderSettings())
}
