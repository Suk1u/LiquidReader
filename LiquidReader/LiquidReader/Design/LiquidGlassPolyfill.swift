//
//  LiquidGlassPolyfill.swift
//  LiquidReader
//
//  Liquid Glass 兼容垫片：遵循 Apple HIG 与 iOS 26+ 前瞻流体玻璃规范，
//  在 iOS 17+ / iOS 18+ / visionOS 上 100% 原生直接编译。
//

import SwiftUI

// MARK: - 1. ButtonStyle: .glass & .glassProminent
public struct LiquidGlassButtonStyle: ButtonStyle {
    public var isProminent: Bool
    
    public init(isProminent: Bool = false) {
        self.isProminent = isProminent
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isProminent {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor.opacity(0.85))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == LiquidGlassButtonStyle {
    static var glass: LiquidGlassButtonStyle {
        LiquidGlassButtonStyle(isProminent: false)
    }
    
    static var glassProminent: LiquidGlassButtonStyle {
        LiquidGlassButtonStyle(isProminent: true)
    }
}

// MARK: - 2. View Modifier: .glassEffect()
public extension View {
    /// 模拟 iOS 26 Liquid Glass 材质背景，并自动响应“减少透明度”无障碍设置
    @ViewBuilder
    func glassEffect(cornerRadius: CGFloat = 16) -> some View {
        #if os(visionOS)
        self.glassBackgroundEffect()
        #else
        self.background {
            LiquidGlassBackground(cornerRadius: cornerRadius)
        }
        #endif
    }
    
    /// 带指定 InsettableShape 的玻璃修饰符
    @ViewBuilder
    func glassEffect<S: InsettableShape>(_ shape: S) -> some View {
        self.background {
            shape
                .fill(.ultraThinMaterial)
                .overlay {
                    shape.strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.35), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                }
        }
    }
}

// MARK: - 3. Liquid Glass 动态材质背景组件
public struct LiquidGlassBackground: View {
    public var cornerRadius: CGFloat = 16
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    
    public init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        
        Group {
            if reduceTransparency {
                shape.fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
            } else {
                shape
                    .fill(.ultraThinMaterial)
                    .overlay {
                        shape.strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.25 : 0.45),
                                    .white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.7
                        )
                    }
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            }
        }
    }
}

// MARK: - 4. Container: GlassEffectContainer
public struct GlassEffectContainer<Content: View>: View {
    private let cornerRadius: CGFloat
    private let content: Content
    
    public init(cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .glassEffect(cornerRadius: cornerRadius)
    }
}
