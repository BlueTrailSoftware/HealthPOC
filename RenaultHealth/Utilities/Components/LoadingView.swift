//
//  LoadingView.swift
//  RenaultHealth
//
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            ContentUnavailableView("Loading", systemImage: "lines.measurement.horizontal")
                .imageScale(.small)
                .symbolEffect(.variableColor)
                .foregroundColor(Color.softPurple)
        }
    }
}

#Preview {
    LoadingView()
}
