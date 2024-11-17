//
//  Constants.swift
//  ricebar
//
//  Created by Joy Liu on 11/9/24.
//

import SwiftUICore

let DEFAULT_BACKGROUND: Color = .init(red: 0.156862745, green: 0.164705882, blue: 0.211764706)



struct ConditionalModifier<TrueModifier: ViewModifier>: ViewModifier {
    let condition: Bool
    let trueModifier: TrueModifier

    init(condition: Bool, trueModifier: TrueModifier) {
        self.condition = condition
        self.trueModifier = trueModifier
    }

    func body(content: Content) -> some View {
        if condition {
            content.modifier(trueModifier)
        } else {
            content
        }
    }
}
