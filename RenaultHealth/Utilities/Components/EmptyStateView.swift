//
//  EmptyStateView.swift
//  RenaultHealth
//
//

import SwiftUI

struct EmptyStateView: View {
    let viewModel: HealthDataViewModel
    var body: some View {
        ContentUnavailableView {
            // Icon & Title
            Label(EmptyStateValues.emptyTitle, systemImage: "heart")
                .font(.largeTitle)
                .symbolRenderingMode(.multicolor)
                .symbolEffect(.pulse)
                .foregroundStyle(Color.softPurple)
        } description: {
            // Instructions
            Text(EmptyStateValues.emptyMessage)
                .font(.footnote)
                .foregroundStyle(Color.softPurple.gradient)

        } actions: {
            // Alternative Actions
            VStack {
                Button {
                    viewModel.refreshData()
                } label: {
                    Label(EmptyStateValues.emptyButtonTry, systemImage: "arrow.circlepath")
                }

                HealthAppButton(type: .labeled)
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.softPurple)
            .tint(Color.deepPurple)
        }
        .padding()
    }
}

#Preview {
    EmptyStateView(viewModel: HealthDataViewModel())
}
