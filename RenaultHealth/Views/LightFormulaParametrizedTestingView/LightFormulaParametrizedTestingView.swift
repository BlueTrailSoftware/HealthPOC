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

    // Collapsables
    @State private var showConstants = true
    @State private var showVariables = true
    @State private var showHistory = true

    // Sheet Results info
    @State private var showingSheet = false

    var body: some View {
        VStack {
            
            ScrollView (showsIndicators: true) {
                VStack {
                    DisclosureGroup(
                        isExpanded: $showConstants,
                        content: {
                            constantsSection()
                                .animatedVisibility(showConstants)
                        },
                        label: {
                            sectionHeader(title: "Constants")
                        }
                    )

                    DisclosureGroup(
                        isExpanded: $showVariables,
                        content: {
                            sleepVarsSection()
                                .animatedVisibility(showVariables)
                        },
                        label: {
                            sectionHeader(title: "Sleep Vars")
                        }
                    )

                    DisclosureGroup(
                        isExpanded: $showHistory,
                        content: {
                            weekSleepSection()
                                .animatedVisibility(showHistory)
                        },
                        label: {
                            sectionHeader(
                                title: "Sleep History",
                                subtitle: "Hours of sleep for the last 7 days"
                            )
                            .foregroundStyle(.black)
                        }
                    )

                    resultsSection()

                    Spacer()
                        .frame(height: 44)
                    
                    Button {
                        viewModel.calculateLightFormula()
                    } label: {
                        Label("Run Calculation", systemImage: "sum")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .modifier(ButtonCapsuleStyle())

                    Spacer()
                        .frame(height: 44)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.resetAllValues()
                viewModel.calculateLightFormula()
            }
        }
        .background (
            LinearGradient(gradient: Gradient(colors: [
                .blue.opacity(0.2),
                .blue.opacity(0.1)
            ]), startPoint: .top, endPoint: .bottom)
        )
        .navigationTitle("Formula Calculation")
        .toolbarBackground(.white, for: .navigationBar)
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
                Label("Reset constants to default", systemImage: "arrow.circlepath")
            }
            .frame(height: 44)
        }
    }
    
    @ViewBuilder
    private func sleepVarsSection() -> some View {
        VStack {
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
                Label("Reset sleep vars to default", systemImage: "arrow.circlepath")
            }
            .frame(height: 44)
        }
    }
    
    @ViewBuilder
    private func weekSleepSection() -> some View {
        
        VStack {
            HStack {
                
                Button {
                    viewModel.sleepHistorySource = .custom
                } label: {
                    
                    Label("Custom Values", systemImage: "square.and.pencil")
                        .fontWeight(viewModel.sleepHistorySource == .custom ? .bold : .regular)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue.opacity(viewModel.sleepHistorySource == .custom ? 0.1 : 0))
                .cornerRadius(12, corners: [.topLeft, .topRight])
                
                Button {
                    viewModel.sleepHistorySource = .healthkit
                } label: {
                    Label("Healthkit Data", systemImage: viewModel.sleepHistorySource == .custom ? "heart" : "heart.fill")
                        .fontWeight(viewModel.sleepHistorySource == .custom ? .regular : .bold)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.purple.opacity(viewModel.sleepHistorySource == .healthkit ? 0.1 : 0))
                .cornerRadius(12, corners: [.topLeft, .topRight])
                .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            
            Spacer()
                .frame(height: 0)
            
            VStack {
            
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
                        
                        ForEach(0 ..< viewModel.sleepDurations.count, id: \.self) { i in
                            
                            HStack {
                                
                                Text("\(viewModel.sleepDurations.count - i - 1) sleeps ago:")
                                    .padding(.leading, 16)
                                    .opacity(0.6)
                                
                                hourPicker(
                                    value: $viewModel.sleepDurations[i],
                                    text:viewModel.sleepDurations[i]
                                )
                                .frame(width: 64)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                viewModel.sleepHistorySource == .custom ? .blue.opacity(0.1) : .purple.opacity(0.1))
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            
            Button {
                viewModel.resetSleepHistory()
            } label: {
                Label("Reset sleep history to optimal hours", systemImage: "clock.arrow.2.circlepath")
            }
            .frame(height: 44)

            Button {
                viewModel.resetAllSleepHistoryTo(value: 0)
            } label: {
                Label("Reset sleep history to 0 hours", systemImage: "trash")
            }
            .frame(height: 44)
        }
    }
    
    @ViewBuilder
    private func resultsSection() -> some View {

        VStack {
            HStack {
                sectionHeader(
                    title: "Result",
                    subtitle: "Result for the current date"
                )
            }
            
            Text (
                viewModel.lightFormulaResult
            )
            .font(.system(size: 32))
            .fontWeight(.bold)
            .opacity(0.4)
            .frame(maxWidth: .infinity, alignment: .trailing)
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
            .opacity(0.9)

            if !subtitle.isEmpty {
                Spacer()
                    .frame(height: 4)
                Text(
                    subtitle
                )
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black.opacity(0.6))
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
                .fontWeight(.semibold)
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
        .font(.title3)
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
        value: Binding<String>,
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.title3)
                .foregroundColor(.black)
        }
        //.contentShape(Rectangle())
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(4)
    }
}

#Preview {
    LightFormulaParametrizedTestingView()
}
