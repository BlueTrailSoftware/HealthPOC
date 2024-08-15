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
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
