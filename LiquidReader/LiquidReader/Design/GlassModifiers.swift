//
//  GlassModifiers.swift
//  LiquidReader
//
//  Liquid Glass 视觉效果辅助修饰符
//

import SwiftUI

public struct AmbientLiquidMesh: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var phase: CGFloat = 0
    var tintColor: Color = .blue
    
    public init(tintColor: Color = .blue) {
        self.tintColor = tintColor
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Color(colorScheme == .dark ? .black : .systemBackground)
                    .ignoresSafeArea()
                
                // 动态微光层，呈现流体玻璃折射感
                Circle()
                    .fill(tintColor.opacity(colorScheme == .dark ? 0.22 : 0.15))
                    .frame(width: size.width * 0.8, height: size.width * 0.8)
                    .blur(radius: 60)
                    .offset(x: -size.width * 0.25, y: -size.height * 0.2)
                
                Circle()
                    .fill(Color.purple.opacity(colorScheme == .dark ? 0.18 : 0.12))
                    .frame(width: size.width * 0.7, height: size.width * 0.7)
                    .blur(radius: 70)
                    .offset(x: size.width * 0.25, y: size.height * 0.25)
            }
        }
        .ignoresSafeArea()
    }
}

public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    public init(cornerRadius: CGFloat = 18) {
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .padding()
            .glassEffect(cornerRadius: cornerRadius)
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 18) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
