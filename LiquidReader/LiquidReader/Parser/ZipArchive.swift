//
//  ZipArchive.swift
//  LiquidReader
//
//  纯原生轻量 ZIP 解压器（利用系统内置 zlib / Compression，零第三方外部依赖）
//

import Foundation
#if canImport(zlib)
import zlib
#endif

public struct ZipEntry {
    public let path: String
    public let data: Data
    public let isDirectory: Bool
}

public enum ZipError: LocalizedError {
    case invalidZipFormat
    case centralDirectoryNotFound
    case decompressionFailed
    case unsupportedCompressionMethod(UInt16)
    
    public var errorDescription: String? {
        switch self {
        case .invalidZipFormat: return "无效的 ZIP/EPUB 文件格式"
        case .centralDirectoryNotFound: return "未找到 ZIP 目录索引"
        case .decompressionFailed: return "数据解压失败"
        case .unsupportedCompressionMethod(let method): return "不支持的压缩算法: \(method)"
        }
    }
}

public final class ZipArchive {
    
    /// 从文件 URL 解压所有条目到内存映射字典 [相对路径: 数据]
    public static func unzip(url: URL) throws -> [String: Data] {
        let fileData = try Data(contentsOf: url, options: .mappedIfSafe)
        return try unzip(data: fileData)
    }
    
    /// 从内存 Data 解析 ZIP 条目
    public static func unzip(data: Data) throws -> [String: Data] {
        var result: [String: Data] = [:]
        
        let eocdSignature: UInt32 = 0x06054b50
        guard let eocdOffset = findLastSignature(eocdSignature, in: data) else {
            // 回退方案：尝试按本地文件头顺序顺序读取
            return try parseLocalHeaders(data: data)
        }
        
        // 解析 Central Directory
        let cdOffset = data.withUnsafeBytes { raw -> UInt32 in
            raw.load(fromByteOffset: eocdOffset + 16, as: UInt32.self)
        }
        let totalEntries = data.withUnsafeBytes { raw -> UInt16 in
            raw.load(fromByteOffset: eocdOffset + 10, as: UInt16.self)
        }
        
        var currentOffset = Int(cdOffset)
        let count = Int(totalEntries)
        
        for _ in 0..<count {
            guard currentOffset + 46 <= data.count else { break }
            let sig = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset, as: UInt32.self) }
            guard sig == 0x02014b50 else { break }
            
            let compressionMethod = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 10, as: UInt16.self) }
            let compressedSize = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 20, as: UInt32.self) }
            let uncompressedSize = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 24, as: UInt32.self) }
            let fileNameLength = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 28, as: UInt16.self) }
            let extraLength = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 30, as: UInt16.self) }
            let commentLength = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 32, as: UInt16.self) }
            let localHeaderOffset = data.withUnsafeBytes { raw in raw.load(fromByteOffset: currentOffset + 42, as: UInt32.self) }
            
            let nameStart = currentOffset + 46
            guard nameStart + Int(fileNameLength) <= data.count else { break }
            let nameData = data.subdata(in: nameStart..<(nameStart + Int(fileNameLength)))
            let filename = String(data: nameData, encoding: .utf8) ?? String(data: nameData, encoding: .ascii) ?? ""
            
            currentOffset += 46 + Int(fileNameLength) + Int(extraLength) + Int(commentLength)
            
            if filename.hasSuffix("/") {
                continue // 目录跳过
            }
            
            // 定位 Local Header 提取实际内容数据
            let localOffset = Int(localHeaderOffset)
            guard localOffset + 30 <= data.count else { continue }
            let localNameLen = data.withUnsafeBytes { raw in raw.load(fromByteOffset: localOffset + 26, as: UInt16.self) }
            let localExtraLen = data.withUnsafeBytes { raw in raw.load(fromByteOffset: localOffset + 28, as: UInt16.self) }
            
            let dataStart = localOffset + 30 + Int(localNameLen) + Int(localExtraLen)
            let dataEnd = dataStart + Int(compressedSize)
            guard dataEnd <= data.count else { continue }
            
            let compressedData = data.subdata(in: dataStart..<dataEnd)
            
            if compressionMethod == 0 {
                // Stored (无压缩)
                result[filename] = compressedData
            } else if compressionMethod == 8 {
                // Deflate (方法8)
                if let decompressed = inflateData(compressedData, expectedSize: Int(uncompressedSize)) {
                    result[filename] = decompressed
                }
            }
        }
        
        return result.isEmpty ? try parseLocalHeaders(data: data) : result
    }
    
    // MARK: - 顺序扫描 Local Headers 保底
    private static func parseLocalHeaders(data: Data) throws -> [String: Data] {
        var result: [String: Data] = [:]
        var offset = 0
        let localSig: UInt32 = 0x04034b50
        
        while offset + 30 <= data.count {
            let sig = data.withUnsafeBytes { raw in raw.load(fromByteOffset: offset, as: UInt32.self) }
            if sig != localSig { break }
            
            let compressionMethod = data.withUnsafeBytes { raw in raw.load(fromByteOffset: offset + 8, as: UInt16.self) }
            let compressedSize = data.withUnsafeBytes { raw in raw.load(fromByteOffset: offset + 18, as: UInt32.self) }
            let uncompressedSize = data.withUnsafeBytes { raw in raw.load(fromByteOffset: offset + 22, as: UInt32.self) }
            let fileNameLength = data.withUnsafeBytes { raw in raw.load(fromByteOffset: offset + 26, as: UInt16.self) }
            let extraLength = data.withUnsafeBytes { raw in raw.load(fromByteOffset: offset + 28, as: UInt16.self) }
            
            let nameStart = offset + 30
            guard nameStart + Int(fileNameLength) <= data.count else { break }
            let nameData = data.subdata(in: nameStart..<(nameStart + Int(fileNameLength)))
            let filename = String(data: nameData, encoding: .utf8) ?? ""
            
            let dataStart = nameStart + Int(fileNameLength) + Int(extraLength)
            let dataEnd = dataStart + Int(compressedSize)
            guard dataEnd <= data.count else { break }
            
            let rawData = data.subdata(in: dataStart..<dataEnd)
            if !filename.hasSuffix("/") {
                if compressionMethod == 0 {
                    result[filename] = rawData
                } else if compressionMethod == 8 {
                    if let decomp = inflateData(rawData, expectedSize: Int(uncompressedSize)) {
                        result[filename] = decomp
                    }
                }
            }
            offset = dataEnd
        }
        return result
    }
    
    // MARK: - 原生 Deflate 解压逻辑 (通过内置 zlib)
    private static func inflateData(_ data: Data, expectedSize: Int) -> Data? {
        #if canImport(zlib)
        var stream = z_stream()
        let initResult = inflateInit2_(&stream, -MAX_WBITS, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard initResult == Z_OK else { return nil }
        defer { inflateEnd(&stream) }
        
        let chunkSize = max(expectedSize, data.count * 2, 4096)
        var outputData = Data(count: chunkSize)
        
        return data.withUnsafeBytes { inputBuffer in
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: inputBuffer.bindMemory(to: Bytef.self).baseAddress)
            stream.avail_in = uInt(data.count)
            
            var decompressed = Data()
            
            while true {
                let status: Int32 = outputData.withUnsafeMutableBytes { outBuffer in
                    stream.next_out = outBuffer.bindMemory(to: Bytef.self).baseAddress
                    stream.avail_out = uInt(outBuffer.count)
                    
                    let res = inflate(&stream, Z_NO_FLUSH)
                    let bytesWritten = outBuffer.count - Int(stream.avail_out)
                    if bytesWritten > 0 {
                        decompressed.append(outBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self), count: bytesWritten)
                    }
                    return res
                }
                
                if status == Z_STREAM_END {
                    break
                } else if status == Z_OK {
                    continue
                } else {
                    return decompressed.isEmpty ? nil : decompressed
                }
            }
            return decompressed
        }
        #else
        return nil
        #endif
    }
    
    private static func findLastSignature(_ signature: UInt32, in data: Data) -> Int? {
        guard data.count > 4 else { return nil }
        let maxSearch = min(data.count, 65535 + 22)
        let start = data.count - maxSearch
        
        for i in stride(from: data.count - 4, through: start, by: -1) {
            let val = data.withUnsafeBytes { raw in
                raw.load(fromByteOffset: i, as: UInt32.self)
            }
            if val == signature {
                return i
            }
        }
        return nil
    }
}
