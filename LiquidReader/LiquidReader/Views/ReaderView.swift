//
//  ReaderView.swift
//  LiquidReader
//
//  阅读主界面：流体悬浮控件联动、章节分页切换与手势交互
//

import SwiftUI

public struct ReaderView: View {
    @Binding var book: Book
    @State private var settings = ReaderSettings()
    @State private var currentChapterIndex: Int
    @State private var progress: Double
    @State private var showControls: Bool = true
    @State private var showTOC: Bool = false
    @State private var showSettings: Bool = false
    @State private var isBookmarked: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    public init(book: Binding<Book>) {
        self._book = book
        self._currentChapterIndex = State(initialValue: book.wrappedValue.lastReadChapterIndex)
        self._progress = State(initialValue: book.wrappedValue.lastReadProgress)
    }
    
    private var currentChapter: Chapter {
        guard !book.chapters.isEmpty else {
            return Chapter(title: "无内容", content: "本书暂无任何可阅读的章节。")
        }
        let safeIndex = max(0, min(currentChapterIndex, book.chapters.count - 1))
        return book.chapters[safeIndex]
    }
    
    public var body: some View {
        ZStack {
            // 背景层
            settings.theme.backgroundColor
                .ignoresSafeArea()
            
            // 正文渲染
            ReaderContentView(
                chapter: currentChapter,
                settings: settings,
                onTap: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showControls.toggle()
                    }
                }
            )
            
            // 顶底浮动工具栏（带渐隐动画）
            if showControls && settings.useLiquidGlassToolbar {
                VStack {
                    ReaderTopBar(
                        title: book.title,
                        isBookmarked: isBookmarked,
                        onBack: {
                            saveProgress()
                            dismiss()
                        },
                        onToggleBookmark: {
                            isBookmarked.toggle()
                        }
                    )
                    
                    Spacer()
                    
                    ReaderBottomBar(
                        currentChapterIndex: $currentChapterIndex,
                        totalChapters: book.chapters.count,
                        progress: $progress,
                        onOpenTOC: { showTOC = true },
                        onOpenSettings: { showSettings = true }
                    )
                    .padding(.bottom, 8)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showTOC) {
            TOCView(book: book, currentChapterIndex: $currentChapterIndex)
        }
        .sheet(isPresented: $showSettings) {
            ReaderSettingsSheetView(settings: settings)
        }
        .onChange(of: currentChapterIndex) { _, newIndex in
            updateProgressForChapter(newIndex)
        }
        .onChange(of: progress) { _, newProgress in
            book.lastReadProgress = newProgress
        }
    }
    
    private func updateProgressForChapter(_ index: Int) {
        guard !book.chapters.isEmpty else { return }
        let calculated = Double(index) / Double(max(book.chapters.count, 1))
        progress = calculated
        saveProgress()
    }
    
    private func saveProgress() {
        book.lastReadChapterIndex = currentChapterIndex
        book.lastReadProgress = progress
    }
}

#Preview {
    ReaderView(book: .constant(SampleData.sampleBook))
}
