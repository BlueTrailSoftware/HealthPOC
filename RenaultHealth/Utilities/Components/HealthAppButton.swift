//
//  HealthAppButton.swift
//  RenaultHealth
//
//

import SwiftUI

enum HealthButtonType {
    case labeled
    case iconic
    case text
}

struct HealthAppButton: View {
    var type: HealthButtonType
    var body: some View {
        Button {
            guard let url = URL(string: "x-apple-health://"),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url)

        } label: {
            switch type {
            case .labeled:
                Label(EmptyStateValues.emptyButtonHealth, systemImage: "heart.fill")
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.large)

            case .iconic:
                Image(systemName: "heart.fill")
                    .imageScale(.large)

            case .text:
                Text(EmptyStateValues.emptyButtonHealth)
            }
        }
    }
}

#Preview {
    HealthAppButton(type: .labeled)
}

#Preview {
    HealthAppButton(type: .iconic)
}

#Preview {
    HealthAppButton(type: .text)
}
