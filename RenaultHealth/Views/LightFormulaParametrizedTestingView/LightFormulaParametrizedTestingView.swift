//
//  LightFormulaParametrizedTestingView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import SwiftUI

struct LightFormulaParametrizedTestingView: View {
    
    @StateObject private var viewModel = LightFormulaParametrizedTestingViewModel()
    
    var body: some View {
        VStack {
            
            ScrollView (showsIndicators: true) {
                VStack {
                    constantsSection()
                    sleepVarsSection()
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private func constantsSection() -> some View {
        VStack {
            sectionHeader(title: "Constants")
            
            labeledValueTextField(
                title: "Decay constant",
                value: $viewModel.decayConstant
            )
            
            labeledValueTextField(
                title: "Low Asimptote",
                value: $viewModel.lowAsymptote
            )
            
            labeledValueTextField(
                title: "Driving decay constant",
                value: $viewModel.decayConstantDriving
            )
            
            Button {
                
            } label: {
                Text("Reset constants to default")
            }
            .frame(height: 44)
        }
    }
    
    @ViewBuilder
    private func sleepVarsSection() -> some View {
        VStack {
            sectionHeader(title: "Sleep Vars")
            
            labeledValueTextField(
                title: "Initial sleep pressure",
                value: $viewModel.initialSleepPressure
            )
            
            labeledValueTextField(
                title: "Circadian amplitude",
                value: $viewModel.circadianAmplitude
            )
            
            labeledValueTextField(
                title: "Circadian acrophase",
                value: $viewModel.circadianAcrophase
            )
            
            labeledValueTextField(
                title: "Max safety time",
                value: $viewModel.maxSafetyTime
            )
            
            labeledValueTextField(
                title: "Wake up hour",
                value: $viewModel.wakeupHourToday
            )
            
            Button {
                
            } label: {
                Text("Reset sleep vars to default")
            }
            .frame(height: 44)
        }
    }
    
    // MARK: - Utils
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text (
                title
            )
            .fontWeight(.bold)
            .font(.title)
            .opacity(0.3)
            
            Spacer()
        }
        .frame(height: 52)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func labeledValueTextField(
        title: String,
        value: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) -> some View {
        
        LabeledContent {
            TextField(
                title,
                text: value
            )
            .textFieldStyle(RoundedTextFieldStyle())
            .keyboardType(.numbersAndPunctuation)
            .numbersOnly(value, includeDecimal: true)
            .onSubmit {
                onSubmit?()
            }
            
        } label: {
            Text(title)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    LightFormulaParametrizedTestingView()
}
