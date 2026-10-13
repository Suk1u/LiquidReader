//
//  EPUBParser.swift
//  LiquidReader
//
//  纯 Swift 原生 EPUB 解析引擎（支持 EPUB 2/3、XMLParser 元数据解析与 HTML 纯文本流提取）
//

import Foundation

public enum EPUBParserError: LocalizedError {
    case fileUnreadable
    case containerNotFound
    case packageOpfNotFound
    case spineEmpty
    
    public var errorDescription: String? {
        switch self {
        case .fileUnreadable: return "无法读取 EPUB 文件"
        case .containerNotFound: return "未找到 META-INF/container.xml 结构"
        case .packageOpfNotFound: return "未找到 OPF 核心包描述文件"
        case .spineEmpty: return "书籍内容脊柱 (Spine) 为空"
        }
    }
}

public final class EPUBParser {
    
    public static func parse(fileURL: URL) throws -> Book {
        let entries = try ZipArchive.unzip(url: fileURL)
        return try parseEntries(entries, fallbackTitle: fileURL.deletingPathExtension().lastPathComponent)
    }
    
    public static func parse(data: Data, fallbackTitle: String = "未命名图书") throws -> Book {
        let entries = try ZipArchive.unzip(data: data)
        return try parseEntries(entries, fallbackTitle: fallbackTitle)
    }
    
    private static func parseEntries(_ entries: [String: Data], fallbackTitle: String) throws -> Book {
        // 1. 读取 META-INF/container.xml
        guard let containerData = entries["META-INF/container.xml"] ?? entries["meta-inf/container.xml"] else {
            throw EPUBParserError.containerNotFound
        }
        
        let containerParser = ContainerXMLParser(data: containerData)
        guard let opfPath = containerParser.parseRootfilePath(),
              let opfData = entries[opfPath] ?? entries[opfPath.removingPercentEncoding ?? opfPath] else {
            throw EPUBParserError.packageOpfNotFound
        }
        
        let opfDir = (opfPath as NSString).deletingLastPathComponent
        
        // 2. 解析 OPF
        let opfParser = PackageOPFParser(data: opfData)
        opfParser.parse()
        
        let bookTitle = opfParser.title.isEmpty ? fallbackTitle : opfParser.title
        let bookAuthor = opfParser.creator.isEmpty ? "佚名" : opfParser.creator
        
        // 3. 提取封面 (如有)
        var coverData: Data? = nil
        if let coverHref = opfParser.coverHref {
            let fullCoverPath = resolvePath(base: opfDir, relative: coverHref)
            coverData = entries[fullCoverPath] ?? entries[coverHref]
        }
        
        // 4. 根据 spine 组织章节
        var chapters: [Chapter] = []
        var order = 0
        
        for itemref in opfParser.spineItemrefs {
            guard let item = opfParser.manifest[itemref] else { continue }
            let fullPath = resolvePath(base: opfDir, relative: item.href)
            
            if let chapterData = entries[fullPath] ?? entries[item.href] {
                let htmlString = String(data: chapterData, encoding: .utf8) ??
                                 String(data: chapterData, encoding: .ascii) ?? ""
                
                let (extractedTitle, cleanText) = HTMLStripper.extractContent(from: htmlString)
                
                // 过滤空白章节
                if !cleanText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let finalChapterTitle = extractedTitle.isEmpty ? "第 \(order + 1) 章" : extractedTitle
                    chapters.append(
                        Chapter(
                            title: finalChapterTitle,
                            href: item.href,
                            content: cleanText,
                            order: order
                        )
                    )
                    order += 1
                }
            }
        }
        
        if chapters.isEmpty {
            // 保底创建一章
            chapters.append(
                Chapter(
                    title: "正文",
                    content: "未检测到可直接阅读的文本内容。",
                    order: 0
                )
            )
        }
        
        return Book(
            title: bookTitle,
            author: bookAuthor,
            coverData: coverData,
            chapters: chapters,
            lastReadChapterIndex: 0,
            lastReadProgress: 0.0
        )
    }
    
    private static func resolvePath(base: String, relative: String) -> String {
        if base.isEmpty || base == "." {
            return relative
        }
        return (base as NSString).appendingPathComponent(relative)
    }
}

// MARK: - XML 解析容器: container.xml
private final class ContainerXMLParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var rootfilePath: String?
    
    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
    }
    
    func parseRootfilePath() -> String? {
        parser.parse()
        return rootfilePath
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName.lowercased() == "rootfile" {
            if let fullPath = attributeDict["full-path"] ?? attributeDict["full_path"] {
                self.rootfilePath = fullPath
            }
        }
    }
}

// MARK: - XML 解析包: content.opf
private final class PackageOPFParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    
    var title = ""
    var creator = ""
    var coverHref: String?
    var coverId: String?
    var manifest: [String: (href: String, mediaType: String)] = [:]
    var spineItemrefs: [String] = []
    
    private var currentElement = ""
    private var currentText = ""
    
    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
    }
    
    func parse() {
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()
        currentText = ""
        
        if currentElement == "item" {
            if let id = attributeDict["id"], let href = attributeDict["href"] {
                let mediaType = attributeDict["media-type"] ?? ""
                manifest[id] = (href: href, mediaType: mediaType)
                
                let properties = attributeDict["properties"] ?? ""
                if properties.contains("cover-image") || id.lowercased().contains("cover") {
                    self.coverHref = href
                }
            }
        } else if currentElement == "itemref" {
            if let idref = attributeDict["idref"] {
                spineItemrefs.append(idref)
            }
        } else if currentElement == "meta" {
            if attributeDict["name"] == "cover", let content = attributeDict["content"] {
                self.coverId = content
                if let item = manifest[content] {
                    self.coverHref = item.href
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let tag = elementName.lowercased()
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if tag.contains("title") && title.isEmpty {
            title = trimmed
        } else if (tag.contains("creator") || tag.contains("author")) && creator.isEmpty {
            creator = trimmed
        }
        
        if let cid = coverId, let item = manifest[cid] {
            coverHref = item.href
        }
    }
}

// MARK: - 轻量 HTML 文本与标题提取器
public struct HTMLStripper {
    public static func extractContent(from html: String) -> (title: String, body: String) {
        var extractedTitle = ""
        
        // 尝试匹配 <title> 标签
        if let titleRange = html.range(of: "(?<=<title>)[^<]+", options: .regularExpression) {
            extractedTitle = String(html[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let h1Range = html.range(of: "(?<=<h1[^>]*>)[^<]+", options: .regularExpression) {
            extractedTitle = String(html[h1Range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 剥离 HTML 标签并将换行标签替换为真换行
        var text = html
        // 移除 <head>...</head>
        text = text.replacingOccurrences(of: "(?s)<head.*?</head>", with: "", options: .regularExpression)
        // 移除 <style>...</style>
        text = text.replacingOccurrences(of: "(?s)<style.*?</style>", with: "", options: .regularExpression)
        // 移除 <script>...</script>
        text = text.replacingOccurrences(of: "(?s)<script.*?</script>", with: "", options: .regularExpression)
        // 替换段落与换行标签
        text = text.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</p>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</div>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</h[1-6]>", with: "\n\n", options: .regularExpression)
        // 剥离剩余所有标签
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // HTML 转义字符还原
        let entities: [String: String] = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&#39;": "'",
            "&mdash;": "—",
            "&ldquo;": "“",
            "&rdquo;": "”",
            "&hellip;": "…"
        ]
        for (entity, char) in entities {
            text = text.replacingOccurrences(of: entity, with: char)
        }
        
        // 压缩多余连续空行
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        
        return (extractedTitle, text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
