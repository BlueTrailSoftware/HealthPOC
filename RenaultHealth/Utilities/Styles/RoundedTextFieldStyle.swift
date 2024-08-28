//
//  RoundedTextFieldStyle.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
    var fontSize: CGFloat = 16
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8)
            .frame(height: 44)
            .background(.blue.opacity(0.1))
            .multilineTextAlignment(.trailing)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
