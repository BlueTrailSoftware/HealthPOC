//
//  MainMenuView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 22/08/24.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView(content: {
            
            VStack {
                
                NavigationLink(destination: HealthDataView()
                ) { Text("Healthkit - User sleep data") }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(.purple)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                NavigationLink(destination: LightFormulaParametrizedTestingView()
                ) { Text("Light Formula calculation") }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(.blue)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
        })
    }
}

#Preview {
    MainMenuView()
}
