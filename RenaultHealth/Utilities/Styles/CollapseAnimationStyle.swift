//
//  CollapseAnimationStyle.swift
//  RenaultHealth
//
//

import SwiftUI

struct CollapseAnimationStyle: ViewModifier {
    var isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.5, anchor: .topTrailing)
            .animation(.easeInOut(duration: 0.2), value: isVisible)
    }
}

extension View {
    func animatedVisibility(_ isVisible: Bool) -> some View {
        self.modifier(CollapseAnimationStyle(isVisible: isVisible))
    }
}
