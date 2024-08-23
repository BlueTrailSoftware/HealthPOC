//
//  LightFormulaParametrizedTestingView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import SwiftUI

struct LightFormulaParametrizedTestingView: View {
    
    @StateObject private var viewModel = LightFormulaParametrizedTestingViewModel()
    
    @State var pickerValues: [Int] = [0]
    
    @FocusState var keyboardIsDisplayed: Bool
    
    var body: some View {
        VStack {
            
            ScrollView (showsIndicators: true) {
                VStack {
                    
                    constantsSection()
                    sleepVarsSection()
                    weekSleepSection()
                    resultsSection()
                    
                    Button {
                        viewModel.calculateLightFormula()
                    } label: {
                        Text("Run calculation")
                    }
                    .frame(height: 44)
                    
                    Spacer()
                        .frame(height: 44)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            viewModel.resetAllValues()
            viewModel.calculateLightFormula()
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
    
    @ViewBuilder
    private func weekSleepSection() -> some View {
        
        VStack {
            
            sectionHeader(
                title: "Sleep History",
                subtitle: "Hours of sleep for the last 7 days"
            )
            
            HStack {
                
                Spacer()
                
                Text("Sleep hours")
                    .fontWeight(.bold)
                
                Spacer()
                    .frame(width: 22)
                
                Rectangle()
                    .frame(width: 1)
                    .padding(.vertical, 22)
                
                VStack {
                    
                    ForEach(0 ..< viewModel.sleepHoursInTheLastDays.count, id: \.self) { i in
                        
                        HStack {
                            
                            Text("\(viewModel.sleepHoursInTheLastDays.count - i - 1) nights ago:")
                                .padding(.leading, 16)
                                .opacity(0.6)
                            
                            hourPicker(
                                value: $viewModel.sleepHoursInTheLastDays[i],
                                text:"\(viewModel.sleepHoursInTheLastDays[i])"
                            )
                            .frame(width: 64)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Button {
                viewModel.resetSleepHistory()
            } label: {
                Text("Reset sleep history to optimal hours")
            }
            .frame(height: 44)
            
            Button {
                viewModel.resetAllSleepHistoryTo(value: 0)
            } label: {
                Text("Reset sleep history to 0 hours")
            }
            .frame(height: 44)
        }
    }
    
    @ViewBuilder
    private func resultsSection() -> some View {
        
        VStack {
            
            sectionHeader(
                title: "Results",
                subtitle: "Showing the safe driving time for every two hours after the wake up hour."
            )
            
            ForEach(viewModel.results, id: \.self) { value in
                HStack {
                    Text (
                        value.title
                    )
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .opacity(0.4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Circle()
                        .frame(width: 22)
                        .foregroundColor(value.color)
                    
                    Text (
                        value.value
                    )
                    .font(.system(size: 16))
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 32)
                    .foregroundColor(.black.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Utils
    
    @ViewBuilder
    private func sectionHeader(
        title: String,
        subtitle: String = ""
    ) -> some View {
        VStack {
            Text (
                title
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontWeight(.bold)
            .font(.title)
            .opacity(0.3)
            
            if !subtitle.isEmpty {
                Spacer()
                    .frame(height: 4)
                Text(
                    subtitle
                )
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.gray)
                .font(.system(size: 14))
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func labeledValueTextField(
        title: String,
        value: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) -> some View {
        
        LabeledContent {
            blueTextField(
                title: title,
                value: value,
                onSubmit: onSubmit
            )
            .frame(width: 88)
        } label: {
            Text(title)
                .fontWeight(.bold)
        }
    }
    
    @ViewBuilder
    private func blueTextField(
        title: String,
        value: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) -> some View {
        
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
    }
    
    @ViewBuilder
    private func hourPicker(
        value: Binding<Int>,
        text: String
    ) -> some View {
        
        Menu {
            Picker(selection: value) {
                ForEach(0 ... 12, id: \.self) { sec in
                    Text("\(sec)").tag("\(sec)")
                }
            } label: {}
        } label: {
            Text(text)
                .font(.system(size: 24))
                .foregroundColor(.black)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(.blue.opacity(0.1))
        .cornerRadius(4)
    }
}

#Preview {
    LightFormulaParametrizedTestingView()
}
