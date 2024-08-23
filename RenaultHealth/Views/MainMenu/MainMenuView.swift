//
//  MainMenuView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 22/08/24.
//

import SwiftUI

struct MainMenuView: View {
    private let menuItems = ["Apple HealthKit\nSleep Data", "Light Formula\nCalculation"]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                LazyVStack(spacing: 0) {
                    ForEach(menuItems.enumerated().map({ $0 }), id: \.element) { index, item in
                        NavigationLink {
                            switch index {
                            case 0:
                                HealthDataView()
                            default:
                                LightFormulaParametrizedTestingView()
                            }
                        } label: {
                            Text(item)
                                .padding()
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .frame(width: geometry.size.width, height: geometry.size.height / 2)
                                .foregroundColor(.white)
                                .background (
                                    LinearGradient(gradient: Gradient(colors: [
                                        index == 0 ? .vibrantPurple : .blue,
                                        index == 0 ? .vibrantPurple.opacity(0.9) : .blue.opacity(0.8) ,
                                        index == 0 ? .deepPurple : .blue
                                    ]), startPoint: .top, endPoint: .center)
                                )

                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MainMenuView()
}
