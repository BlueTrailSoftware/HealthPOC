//
//  LightFormulaParametrizedTestingView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import SwiftUI

struct LightFormulaParametrizedTestingView: View {
    
    @StateObject private var viewModel = LightFormulaParametrizedTestingViewModel()
    
    @FocusState var keyboardIsDisplayed: Bool
    
    var body: some View {
        VStack {
            
            ScrollView (showsIndicators: true) {
                VStack {
                    
                    Button {
                        viewModel.calculateLightFormula()
                    } label: {
                        Text("Run demonstration")
                    }
                    .frame(height: 44)
                    
                    constantsSection()
                    sleepVarsSection()
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            viewModel.resetAllValues()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                    .frame(maxWidth: .infinity)
                Button("Done") {
                    print("Clicked")
                    keyboardIsDisplayed = false
                }
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
                viewModel.resetConstants()
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
                viewModel.resetSleepVars()
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
            .keyboardType(.decimalPad)
            .numbersOnly(value, includeDecimal: true)
            .focused($keyboardIsDisplayed)
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
