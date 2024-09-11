//
//  SleepDataView.swift
//  RenaultHealth
//
//  Created by Blue Trail Software on 18/07/24.
//

import SwiftUI

struct HealthDataView: View {
    
    @State private var viewModel = HealthDataViewModel()
    @State private var showError = false

    var body: some View {
        
        VStack {
            if !viewModel.isRefreshing {
                if viewModel.errorType == nil {
                    healthView()

                } else {
                    EmptyStateView {
                        viewModel.refreshTripTime()
                    }
                    .onAppear {
                        showError.toggle()
                    }
                    .alert("Error", isPresented: $showError) {
                        Button("Close", role: .cancel) { }
                    } message: {
                        Text(viewModel.errorType?.message ?? "Null")
                    }
                }

            } else {
               LoadingView()
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            viewModel.requestHKPermission()
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .background (
            LinearGradient(gradient: Gradient(colors: [
                .vibrantPurple,
                .vibrantPurple.opacity(0.9),
                .vibrantPurple.opacity(0.8),
                .vibrantPurple.opacity(0.7),
                .vibrantPurple
            ]), startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: Main Views
    @ViewBuilder
    private func healthView() -> some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    mainHeader()
                    tripInfoCard()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
        }
        .background(.clear)
    }

    // MARK: Headers
    @ViewBuilder
    private func mainHeader() -> some View {
        
        ZStack{
            HStack {
                Text(
                    "Trip Simulation"
                )
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.leading, 8)

                Spacer()
            }

            if viewModel.tripStatus == .none {
                HStack(spacing: 10) {
                    Spacer()

                    HealthAppButton(type: .iconic)

                    Button {
                        viewModel.refreshTripTime()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .imageScale(.large)
                    }
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 8)
            }

        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
    }
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text (
                title
            )
            .fontWeight(.bold)
            .font(.title)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .foregroundColor(Color.softPurple)
    }

    @ViewBuilder
    private func titleValueCell(
        title: String,
        titleColor: Color? = Color.black.opacity(0.6),
        value: String,
        valueColor: Color? = Color.black.opacity(0.6),
        highlighted: Bool? = false,
        highlightedColor: Color? = Color.white
    ) -> some View {

        HStack{

            Text(title)
                .foregroundColor(titleColor)
                .fontWeight(highlighted ?? false ? .bold : .regular)
                .font(.body)

            Spacer()

            Text(value)
                .padding(8)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
                .background(highlighted ?? false ? highlightedColor : .white)
                .cornerRadius(8)
        }
        .frame(height: 44)
        .padding(.leading, 16)
    }
    
    @ViewBuilder
    private func tripInfoCard() -> some View {
        
        ContentCard(
            content:
                VStack {
                    if viewModel.canStartTrip {
                        HStack {
                            if viewModel.tripStatus == .running {
                                Image(systemName: "car.fill")
                            }

                            Text(viewModel.tripMessage)
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.tripMessageColor)

                        if viewModel.tripStatus != .none {

                            titleValueCell(
                                title: "Trip start",
                                value: viewModel.startTripDate.string(withFormat: .readable)
                            )

                            Divider()

                            titleValueCell(
                                title: "Trip time before rest",
                                value: "\(viewModel.tripTimeBeforeRest.formattedTime())",
                                valueColor: .white,
                                highlighted: true,
                                highlightedColor: .teal
                            )

                            Divider()

                            titleValueCell(
                                title: "Trip elapsed time",
                                value: "\(viewModel.elapsedTime.verboseTimeString(includeSeconds: true))"
                            )
                        }
                        
                        HStack {
                            Spacer()

                            Button {
                                viewModel.toggleTrip()
                            } label: {
                                Label(
                                    viewModel.tripActionButtonText,
                                    systemImage: viewModel.tripStatus == .running
                                    ? "stop.fill"
                                    : viewModel.tripStatus == .completed
                                    ? "bed.double.fill" : "play.fill"
                                )
                                .padding()
                            }
                            .modifier(ButtonCapsuleStyle(backgroundColor: viewModel.tripActionButtonBackground))

                            Spacer()
                        }
                    } else {
                        // Error Happened
                        if let error = viewModel.errorType {
                            Image(systemName: "xmark.octagon.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.red)
                                .symbolEffect(.pulse)

                            Text(error.message)
                                .font(.title3)
                                .foregroundStyle(.black)
                        }
                        else {
                            // User is not able to Drive due to result on 'tripTimeBeforeRest' is Zero
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.red)
                                .symbolEffect(.pulse)

                            Text("You cannot drive")
                                .font(.title)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)

                            Text("Please take a rest")
                                .font(.title3)
                                .foregroundStyle(.gray)
                        }
                    }
                }
        )
    }
}

#Preview {
   HealthDataView()
}
