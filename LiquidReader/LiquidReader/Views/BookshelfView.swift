//
//  BookshelfView.swift
//  LiquidReader
//
//  书架主界面：流体网格布局、搜索筛选、文件导入与阅读进度一览
//

import SwiftUI
import UniformTypeIdentifiers

public struct BookshelfView: View {
    @State private var books: [Book] = SampleData.sampleLibrary
    @State private var searchText: String = ""
    @State private var isImporting: Bool = false
    @State private var importErrorMessage: String? = nil
    @State private var showingErrorAlert: Bool = false
    @State private var selectedBookForReading: Book? = nil
    
    public init() {}
    
    private var filteredBooks: [Book] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return books
        } else {
            return books.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 155, maximum: 200), spacing: 18)
    ]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // 流体背景氛围层
                AmbientLiquidMesh(tintColor: .cyan)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // 顶部欢迎与阅读概览卡片
                        VStack(alignment: .leading, spacing: 8) {
                            Text("探索阅读新境")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                                .textCase(.uppercase)
                            
                            Text("流光视界，沉浸翻阅")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            HStack(spacing: 16) {
                                Label("书架藏书: \(books.count) 本", systemImage: "books.vertical.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Label("iOS 26 Liquid Glass 质感", systemImage: "sparkles")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(cornerRadius: 20)
                        
                        // 书架网格
                        if filteredBooks.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "books.vertical")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary.opacity(0.6))
                                
                                Text("书架空空如也")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Text("点击右上角 + 按钮导入本地 EPUB 文件，或重置内置图书。")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 32)
                                
                                Button("恢复示例书籍") {
                                    books = SampleData.sampleLibrary
                                }
                                .buttonStyle(.glassProminent)
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(filteredBooks) { book in
                                    Button {
                                        selectedBookForReading = book
                                    } label: {
                                        BookCardView(book: book)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("流体书架")
            .searchable(text: $searchText, prompt: "搜索书名或作者")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isImporting = true
                    } label: {
                        Label("导入 EPUB", systemImage: "plus")
                    }
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("导入本地 EPUB 书籍")
                    
                    Menu {
                        Button("重置所有示例书籍") {
                            books = SampleData.sampleLibrary
                        }
                        Button("清空书架", role: .destructive) {
                            books.removeAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("书架更多操作")
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [
                    UTType(filenameExtension: "epub") ?? .data,
                    UTType.data
                ],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .alert("导入提示", isPresented: $showingErrorAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(importErrorMessage ?? "未能成功解析该 EPUB 文件。")
            }
            .fullScreenCover(item: $selectedBookForReading) { book in
                if let index = books.firstIndex(where: { $0.id == book.id }) {
                    ReaderView(book: $books[index])
                }
            }
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        do {
            guard let selectedURL = try result.get().first else { return }
            
            // 安全范围资源访问
            let canAccess = selectedURL.startAccessingSecurityScopedResource()
            defer {
                if canAccess {
                    selectedURL.stopAccessingSecurityScopedResource()
                }
            }
            
            // 使用纯原生 EPUB 解析器
            let parsedBook = try EPUBParser.parse(fileURL: selectedURL)
            books.insert(parsedBook, at: 0)
        } catch {
            importErrorMessage = "导入失败: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}

#Preview {
    BookshelfView()
}
