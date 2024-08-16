//
//  ContentCard.swift
//  RenaultHealth
//
//

import SwiftUI

struct ContentCard<T: View>: View {
    let content: T

    var body: some View {
        VStack {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(16)
        .scrollTransition { content, phase in
            content
                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                .offset(x: phase.isIdentity ? 0 : 10)
        }
    }
}
