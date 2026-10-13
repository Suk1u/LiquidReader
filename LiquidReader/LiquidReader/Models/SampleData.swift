//
//  SampleData.swift
//  LiquidReader
//
//  内置示例书籍数据，保证纯净 Xcode Canvas 预览与启动后即开即读
//

import Foundation

public struct SampleData {
    public static let sampleBook: Book = {
        let chapter1 = Chapter(
            title: "第一章 · 流体视界",
            href: "chapter1.xhtml",
            content: """
            在未来的数字界面中，光线不再是简单的背景点缀，而是拥有折射率与流动形态的介质。

            iOS 26 的设计语言将“空间流动性”与“拟态透明度”推向极致。界面不再依赖厚重繁琐的投影层级，而是利用系统的微米级折射、环境自适应光斑以及超薄流体玻璃材质（Liquid Glass），让阅读内容本身成为视线的唯一焦点。

            当读者在指尖轻抚屏幕滑动翻页时，文字若隐若现地浮动于晶莹的玻璃曲面之上。周围环境的明暗变幻，会自然透过底层的材质扩散出温润柔和的光晕。这种体验既不同于传统纸质书籍的静止沉稳，亦完全摆脱了早期扁平化 UI 的干瘪生硬。

            这不仅是视觉技术的迭代，更是一场关于数字阅读沉浸感的回归。
            """,
            order: 0
        )
        
        let chapter2 = Chapter(
            title: "第二章 · 材质的触感",
            href: "chapter2.xhtml",
            content: """
            材质是有生命的。每一个界面控件，都遵循着最纯粹的 Apple Human Interface Guidelines 规范。

            在超薄材质（.ultraThinMaterial）之上，微弱的白色渐变高光边框（Stroke Border）界定了交互的物理边界。当你轻轻按压悬浮工具栏上的按钮，微小的形变与回弹触感（Haptic Feedback）会精准地通过触觉引擎传递到指尖。

            同时，系统的包容性设计（Accessibility）在此刻发挥着不可替代的基石作用。当开启“减少透明度（Reduce Transparency）”辅助功能时，流体玻璃会自动褪去繁复的模糊动效，转换为高对比度的纯色柔和垫底，确保每一位读者都能获得清晰、舒适且无障碍的阅读过程。
            """,
            order: 1
        )
        
        let chapter3 = Chapter(
            title: "第三章 · 数字书香的延续",
            href: "chapter3.xhtml",
            content: """
            从羊皮纸到现代活字印刷，人类记录思想的载体经历了千百年的更迭。

            而今天，在这一方流光溢彩的屏幕之中，我们通过自包含的轻量 EPUB 解析引擎，重新点亮了成千上万部文学经典。无论是莎士比亚的诗篇，还是浩瀚的技术典籍，皆能在流体玻璃的光影中娓娓道来。

            静下心来，调低环境光线，切换至“羊皮纸”或“暮色”主题，开启你今天的阅读之旅吧。
            """,
            order: 2
        )
        
        return Book(
            id: "sample-ios26-manifesto",
            title: "流体玻璃与未来阅读指南",
            author: "Antigravity Studio",
            chapters: [chapter1, chapter2, chapter3],
            lastReadChapterIndex: 0,
            lastReadProgress: 0.15
        )
    }()
    
    public static let sampleLibrary: [Book] = [
        sampleBook,
        Book(
            id: "sample-classic-alice",
            title: "爱丽丝漫游奇境记",
            author: "刘易斯·卡罗尔",
            chapters: [
                Chapter(
                    title: "第一章 · 掉进兔子洞",
                    content: "爱丽丝坐在河岸边，姐姐正在看书，而她却无所事事，很快就觉得百无聊赖了。她几次探头去看姐姐手里的书，可书上既没有插图，也没有对话……",
                    order: 0
                )
            ],
            lastReadChapterIndex: 0,
            lastReadProgress: 0.42
        ),
        Book(
            id: "sample-tech-swift",
            title: "Swift 现代并发与界面哲学",
            author: "SwiftUI Core Team",
            chapters: [
                Chapter(
                    title: "前言 · 声明式空间计算",
                    content: "从单一布局树到声明式并发响应式模型，现代 Swift 语言正在重塑开发者与系统底层的对话范式……",
                    order: 0
                )
            ],
            lastReadChapterIndex: 0,
            lastReadProgress: 0.88
        )
    ]
}
