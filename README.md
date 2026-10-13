# LiquidReader (流体阅读)

> 遵循 **Apple Human Interface Guidelines (HIG)** 与前瞻 **iOS 26 Liquid Glass (流体流动玻璃材质)** 设计哲学的原生 Swift / SwiftUI EPUB 阅读器。

[![Build Unsigned IPA](https://github.com/your-username/LiquidReader/actions/workflows/build-ipa.yml/badge.svg)](../../actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B%20%7C%20iOS%2018%2B%20%7C%20visionOS-black.svg)]()

---

## 视觉与设计语言 (iOS 26 Liquid Glass)

- **超薄材质与折射微光**: 基于系统的 `.ultraThinMaterial` 与动态模糊，结合自适应高光描边（Stroke Border），无需多余投影即可保持优雅对比度。
- **全量无障碍集成**: 尊重系统“减少透明度 (Reduce Transparency)”等设置，所有按钮与滑块均具备完整的 `.accessibilityLabel` 与 `.accessibilityValue`。
- **自包含 Polyfill 垫片**: 内置零依赖 `LiquidGlassPolyfill.swift`，在 Xcode 15 / 16 / 17 中 100% 原生直接编译。

---

## 核心功能

1. **流体书架 (Bookshelf)**:
   - 自适应网格布局与书架卡片。
   - 本地图书导入（基于系统 `.fileImporter` 与 `UniformTypeIdentifiers`）。
   - 快速搜索书名与作者。
   - 内置示例图书，启动即读。
2. **沉浸阅读器 (Reader)**:
   - 双态悬浮流体玻璃工具栏（点按正文随心显隐）。
   - 纸张质感与色彩主题：羊皮纸、纯白、复古、暮色、OLED 极黑。
   - 排版字形切换：宋体/衬线、黑体/标准、圆体/柔和、等宽。
   - 字号与行距动态滑块调节。
   - 目录导航（TOC）与实时阅读进度同步。
3. **零外部依赖 EPUB 解析器**:
   - 利用系统内置 `zlib` 与 `Foundation.XMLParser` 实现轻量解压与 OPF/Spine/XHTML 解析。
   - HTML 标签自动格式化为自然段落并还原字符实体。

---

## 项目结构

```text
LiquidReader/
├── LiquidReader.xcodeproj/            # 标准 Xcode 工程配置与共享 Scheme
└── LiquidReader/
    ├── App/                          # 应用入口 (LiquidReaderApp.swift)
    ├── Design/                       # Liquid Glass 垫片、主题系统与修饰符
    ├── Models/                       # 核心数据模型 (Book, Chapter, Settings)
    ├── Parser/                       # 原生纯 Swift ZIP & EPUB 解析模块
    ├── Views/                        # 书架、阅读器、目录与排版组件
    └── Resources/                    # Info.plist & Assets.xcassets
.github/
└── workflows/
    └── build-ipa.yml                 # GitHub Actions 自动编译未签名 IPA
```

---

## 编译与打包

### 本地构建 (Xcode)
打开 `LiquidReader/LiquidReader.xcodeproj`，选择 iOS 17+ 模拟器或真机即可直接运行。

### 命令行生成未签名 IPA
```bash
xcodebuild -project LiquidReader/LiquidReader.xcodeproj \
  -scheme LiquidReader \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/LiquidReader.xcarchive \
  archive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  AD_HOC_CODE_SIGNING_ALLOWED=YES

mkdir -p build/Payload
cp -R build/LiquidReader.xcarchive/Products/Applications/LiquidReader.app build/Payload/
cd build && zip -r -y LiquidReader-unsigned.ipa Payload
```

### GitHub Actions CI
代码推送到 GitHub 仓库的 `main` 或 `master` 分支后，GitHub Actions 工作流将自动触发，在 `macos-14` 环境下完成编译，并将 `LiquidReader-unsigned.ipa` 上传到 Artifacts 供下载。
