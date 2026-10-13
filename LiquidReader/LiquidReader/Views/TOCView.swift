//
//  TOCView.swift
//  LiquidReader
//
//  目录与书签导航面板：支持快速章节跳转与 Liquid Glass 质感高亮
//

import SwiftUI

public struct TOCView: View {
    public let book: Book
    @Binding var currentChapterIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    public init(book: Book, currentChapterIndex: Binding<Int>) {
        self.book = book
        self._currentChapterIndex = currentChapterIndex
    }
    
    private var filteredChapters: [(index: Int, chapter: Chapter)] {
        let indexed = book.chapters.enumerated().map { ($0.offset, $0.element) }
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return indexed
        } else {
            return indexed.filter {
                $0.1.title.localizedCaseInsensitiveContains(searchText) ||
                $0.1.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredChapters, id: \.chapter.id) { item in
                        Button {
                            currentChapterIndex = item.index
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(item.index == currentChapterIndex ? Color.accentColor : Color.secondary.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    
                                    Text("\(item.index + 1)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(item.index == currentChapterIndex ? .white : .secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.chapter.title)
                                        .font(.body.weight(item.index == currentChapterIndex ? .semibold : .regular))
                                        .foregroundStyle(item.index == currentChapterIndex ? Color.accentColor : .primary)
                                        .lineLimit(2)
                                    
                                    Text("\(item.chapter.content.count) 字")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if item.index == currentChapterIndex {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("第 \(item.index + 1) 章: \(item.chapter.title)")
                        .accessibilityValue(item.index == currentChapterIndex ? "当前正在阅读" : "\(item.chapter.content.count)字")
                    }
                } header: {
                    Text("共 \(book.chapters.count) 个章节")
                }
            }
            .searchable(text: $searchText, prompt: "在目录与内容中搜索章节")
            .scrollContentBackground(.hidden)
            .background(AmbientLiquidMesh(tintColor: .teal))
            .navigationTitle("目录导航")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("关闭目录")
                }
            }
        }
    }
}

#Preview {
    TOCView(
        book: SampleData.sampleBook,
        currentChapterIndex: .constant(0)
    )
}
