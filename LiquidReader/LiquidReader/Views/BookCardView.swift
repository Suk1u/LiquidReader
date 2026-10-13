//
//  BookCardView.swift
//  LiquidReader
//
//  书架卡片组件：支持 Liquid Glass 材质、自适应光影与无障碍播报
//

import SwiftUI

public struct BookCardView: View {
    public let book: Book
    @Environment(\.colorScheme) private var colorScheme
    
    public init(book: Book) {
        self.book = book
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 书籍封面或艺术占位
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.3),
                                Color.purple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(0.72, contentMode: .fit)
                
                VStack(spacing: 8) {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(Color.accentColor)
                    
                    Text(book.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 10)
                        .foregroundStyle(.primary)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            
            // 元数据信息
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(book.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // 阅读进度指示条
                ProgressView(value: book.lastReadProgress)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
                    .padding(.top, 2)
                    .accessibilityLabel("阅读进度")
                    .accessibilityValue("\(Int(book.lastReadProgress * 100))%")
            }
        }
        .padding(10)
        .glassEffect(cornerRadius: 18)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("书籍: \(book.title), 作者: \(book.author)")
        .accessibilityValue("已读 \(Int(book.lastReadProgress * 100))%")
        .accessibilityHint("轻点打开阅读")
    }
}

#Preview {
    ZStack {
        AmbientLiquidMesh()
        BookCardView(book: SampleData.sampleBook)
            .frame(width: 170)
    }
}
