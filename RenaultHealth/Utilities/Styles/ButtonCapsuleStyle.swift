//
//  ButtonCapsuleStyle.swift
//  RenaultHealth
//
//

import SwiftUI

struct ButtonCapsuleStyle: ViewModifier {
    var backgroundColor: Color = .blue

    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
