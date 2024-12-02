//
//  ShaderLogic.swift
//  ricebar
//
//  Created by Joy Liu on 11/17/24.
//

import SwiftUI

extension View {
    func colorShader() -> some View {
        modifier(ColorShader())
    }
    
    func sizeAwareColorShader() -> some View {
            modifier(SizeAwareColorShader())
    }
    func timeVaryingShader() -> some View {
            modifier(TimeVaryingShader())
    }
    func timeVaryingShaderLight() -> some View {
            modifier(TimeVaryingShaderLight())
    }
}

struct ColorShader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .colorEffect(ShaderLibrary.color())
    }
}
struct SizeAwareColorShader: ViewModifier {
    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content
                .colorEffect(ShaderLibrary.sizeAwareColor(
                    .float2(proxy.size)
                ))
        }
    }
}

struct TimeVaryingShader: ViewModifier {
    @StateObject private var userSettings = UserSettings.shared
    private let startDate = Date()
    
    func body(content: Content) -> some View {
        TimelineView(.animation) { _ in
            content.visualEffect { content, proxy in
                content
                    .colorEffect(
                        ShaderLibrary.timeVaryingColor(
                            .float2(proxy.size),
                            .float(startDate.timeIntervalSinceNow),
                            .float4(
                                Float(userSettings.shaderBaseColor.cgColor?.components?[0] ?? 0),
                                Float(userSettings.shaderBaseColor.cgColor?.components?[1] ?? 0),
                                Float(userSettings.shaderBaseColor.cgColor?.components?[2] ?? 0),
                                Float(userSettings.shaderBaseColor.cgColor?.components?[3] ?? 1)
                            )
                        )
                    )
            }
        }
    }
}


struct TimeVaryingShaderLight: ViewModifier {
    
    private let startDate = Date()
    
    func body(content: Content) -> some View {
        TimelineView(.animation) { _ in
            content.visualEffect { content, proxy in
                content
                    .colorEffect(
                        ShaderLibrary.timeVaryingColorLight(
                            .float2(proxy.size),
                            .float(startDate.timeIntervalSinceNow)
                        )
                    )
            }
        }
    }
}
