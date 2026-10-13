//
//  Book.swift
//  LiquidReader
//
//  书籍核心数据模型
//

import Foundation

public struct Book: Identifiable, Hashable, Codable {
    public let id: String
    public var title: String
    public var author: String
    public var coverImageName: String?
    public var coverData: Data?
    public var chapters: [Chapter]
    public var lastReadChapterIndex: Int
    public var lastReadProgress: Double // 0.0 ~ 1.0
    public var addedDate: Date
    public var totalWordCount: Int
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        author: String = "未知作者",
        coverImageName: String? = nil,
        coverData: Data? = nil,
        chapters: [Chapter] = [],
        lastReadChapterIndex: Int = 0,
        lastReadProgress: Double = 0.0,
        addedDate: Date = Date(),
        totalWordCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageName = coverImageName
        self.coverData = coverData
        self.chapters = chapters
        self.lastReadChapterIndex = lastReadChapterIndex
        self.lastReadProgress = lastReadProgress
        self.addedDate = addedDate
        self.totalWordCount = totalWordCount > 0 ? totalWordCount : chapters.reduce(0) { $0 + $1.content.count }
    }
}
