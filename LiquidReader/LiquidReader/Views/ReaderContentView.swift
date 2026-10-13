//
//  ReaderContentView.swift
//  LiquidReader
//
//  章节正文渲染引擎：自适应排版、动态字号与流体背景
//

import SwiftUI

public struct ReaderContentView: View {
    public let chapter: Chapter
    public let settings: ReaderSettings
    public let onTap: () -> Void
    
    public init(chapter: Chapter, settings: ReaderSettings, onTap: @escaping () -> Void) {
        self.chapter = chapter
        self.settings = settings
        self.onTap = onTap
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // 章节标题
                Text(chapter.title)
                    .font(.system(size: settings.fontSize + 8, weight: .bold, design: settings.fontDesign.fontDesign))
                    .foregroundStyle(settings.theme.textColor)
                    .padding(.top, 40)
                    .padding(.bottom, 8)
                
                // 正文排版
                Text(chapter.content)
                    .font(.system(size: settings.fontSize, weight: .regular, design: settings.fontDesign.fontDesign))
                    .lineSpacing(settings.lineSpacing)
                    .foregroundStyle(settings.theme.textColor)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
                
                // 章末分隔
                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .foregroundStyle(settings.theme.secondaryTextColor)
                        .padding(.vertical, 32)
                    Spacer()
                }
            }
            .padding(.horizontal, settings.horizontalPadding)
            .padding(.bottom, 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
        .background(settings.theme.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    ReaderContentView(
        chapter: SampleData.sampleBook.chapters[0],
        settings: ReaderSettings(),
        onTap: {}
    )
}
