//
//  View+Extension.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import Foundation
import SwiftUI

extension View {
    func numbersOnly(_ text: Binding<String>, includeDecimal: Bool = false) -> some View {
        self.modifier(NumbersOnlyViewModifier(text: text, includeDecimal: includeDecimal))
    }
}
