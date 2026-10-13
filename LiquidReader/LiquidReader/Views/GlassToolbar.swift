//
//  GlassToolbar.swift
//  LiquidReader
//
//  阅读器顶底悬浮流体玻璃工具栏
//

import SwiftUI

public struct ReaderTopBar: View {
    public let title: String
    public let onBack: () -> Void
    public let onToggleBookmark: () -> Void
    public var isBookmarked: Bool = false
    
    public init(
        title: String,
        isBookmarked: Bool = false,
        onBack: @escaping () -> Void,
        onToggleBookmark: @escaping () -> Void
    ) {
        self.title = title
        self.isBookmarked = isBookmarked
        self.onBack = onBack
        self.onToggleBookmark = onToggleBookmark
    }
    
    public var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.glass)
            .accessibilityLabel("返回书架")
            
            Spacer()
            
            Text(title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .glassEffect(cornerRadius: 12)
            
            Spacer()
            
            Button(action: onToggleBookmark) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.body)
                    .foregroundStyle(isBookmarked ? Color.accentColor : Color.primary)
            }
            .buttonStyle(.glass)
            .accessibilityLabel(isBookmarked ? "取消书签" : "添加书签")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

public struct ReaderBottomBar: View {
    @Binding var currentChapterIndex: Int
    public let totalChapters: Int
    @Binding var progress: Double
    public let onOpenTOC: () -> Void
    public let onOpenSettings: () -> Void
    
    public init(
        currentChapterIndex: Binding<Int>,
        totalChapters: Int,
        progress: Binding<Double>,
        onOpenTOC: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self._currentChapterIndex = currentChapterIndex
        self.totalChapters = totalChapters
        self._progress = progress
        self.onOpenTOC = onOpenTOC
        self.onOpenSettings = onOpenSettings
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // 进度控制条
            HStack(spacing: 12) {
                Button {
                    if currentChapterIndex > 0 {
                        currentChapterIndex -= 1
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.caption)
                }
                .buttonStyle(.glass)
                .disabled(currentChapterIndex <= 0)
                .accessibilityLabel("上一章")
                
                Slider(value: $progress, in: 0...1)
                    .tint(.accentColor)
                    .accessibilityLabel("阅读进度条")
                    .accessibilityValue("\(Int(progress * 100))%")
                
                Button {
                    if currentChapterIndex < totalChapters - 1 {
                        currentChapterIndex += 1
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.caption)
                }
                .buttonStyle(.glass)
                .disabled(currentChapterIndex >= totalChapters - 1)
                .accessibilityLabel("下一章")
            }
            .padding(.horizontal, 8)
            
            // 核心功能按键
            HStack {
                Button(action: onOpenTOC) {
                    Label("目录", systemImage: "list.bullet")
                }
                .buttonStyle(.glass)
                .accessibilityLabel("打开章节目录")
                
                Spacer()
                
                Text("\(currentChapterIndex + 1) / \(max(totalChapters, 1)) 章 · \(Int(progress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: onOpenSettings) {
                    Label("排版", systemImage: "textformat.size")
                }
                .buttonStyle(.glass)
                .accessibilityLabel("打开排版与主题设置")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(cornerRadius: 24)
        .padding(.horizontal, 16)
    }
}
