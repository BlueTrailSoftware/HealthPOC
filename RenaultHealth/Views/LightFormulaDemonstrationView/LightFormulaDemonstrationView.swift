//
//  LightFormulaView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 20/08/24.
//

import SwiftUI

struct LightFormulaDemonstrationView: View {
    
    @StateObject private var viewModel = LightFormulaDemonstrationViewModel()
    
    var body: some View {

        ScrollView(showsIndicators: true) {
            VStack {
                ForEach(viewModel.formulaResults, id: \.self) { item in
                    resultCell(item: item)
                }
            }
            .onAppear {
                viewModel.runDemonstration()
            }
        }
    }
    
    // MARK: Headers
    @ViewBuilder
    private func resultCell(
        item: LightFormulaDemonstrationResultItem
    ) -> some View {
        VStack {
            Text(item.title)
            
            HStack {
                ForEach(item.values, id: \.self) { value in
                    VStack {
                        Text (
                            value.title
                        )
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .opacity(0.4)
                        
                        Spacer()
                            .frame(height: 8)
                        
                        Text (
                            value.value
                        )
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(.green)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LightFormulaDemonstrationView()
}
