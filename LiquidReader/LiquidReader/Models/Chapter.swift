//
//  Chapter.swift
//  LiquidReader
//
//  EPUB 章节数据模型
//

import Foundation

public struct Chapter: Identifiable, Hashable, Codable {
    public let id: String
    public let title: String
    public let href: String
    public let content: String
    public let order: Int
    
    public init(id: String = UUID().uuidString, title: String, href: String = "", content: String, order: Int = 0) {
        self.id = id
        self.title = title
        self.href = href
        self.content = content
        self.order = order
    }
}
