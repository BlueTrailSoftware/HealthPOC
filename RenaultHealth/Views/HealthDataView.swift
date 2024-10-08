//
//  SleepDataView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import SwiftUI

struct HealthDataView: View {
    
    @StateObject private var viewModel = HealthDataViewModel()

    var body: some View {
        
        VStack {
            if !viewModel.isRefreshing {
                if !viewModel.allSleepSessionValues.isEmpty {
                    healthView()

                } else {
                    EmptyStateView(viewModel: viewModel)
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
            viewModel.refreshData()
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .background (
            LinearGradient(gradient: Gradient(colors: [
                .vibrantPurple,
                .vibrantPurple.opacity(0.9),
                .vibrantPurple.opacity(0.8),
                .vibrantPurple.opacity(0.7),
                .white
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

                    sectionHeader(title: "Current Trip")
                    tripInfoCard()

                    sectionHeader(title: "Last sleep")
                    sleepDataCard(viewModel.lastSleepSessionValues)

                    sectionHeader(title: "Longest sleep")
                    sleepDataCard(viewModel.longestSleepSessionValues)

                    sectionHeader(title: "All sleep sessions")
                    ForEach(viewModel.allSleepSessionValues, id: \.self) {
                        sleepDataCard($0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .refreshable {
                viewModel.refreshData()
            }
        }
        .background(.clear)
    }

    // MARK: Headers
    @ViewBuilder
    private func mainHeader() -> some View {
        
        ZStack{
            HStack {
                Text(
                    "Health Data"
                )
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.leading, 8)

                Spacer()
            }

            HStack(spacing: 10) {
                Spacer()

                HealthAppButton(type: .iconic)

                Button {
                    viewModel.refreshData()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .imageScale(.large)
                }
            }
            .foregroundColor(.purple)
            .padding(.horizontal, 8)
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
    private func contentCardHeader(
        _ title: String,
        color: Color? = .black.opacity(0.5)
    ) -> some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 24))
            .fontWeight(.light)
            .foregroundColor(color ?? .black.opacity(0.5))
            .padding(.bottom, 18)
    }

    // MARK: Cells
    @ViewBuilder
    private func sleepSegmentCell(
        _ value: SleepStageDisplayValues
    ) -> some View {
        HStack {
            VStack(spacing: 8) {
                Text(
                    value.start
                )

                Text(
                    value.end
                )
            }
            .foregroundStyle(Color.deepPurple)
            .font(.footnote)
            .opacity(0.6)

            Spacer()
            Divider()
                .background(Color.deepPurple)
            Spacer()

            Text(
                value.title
            )
            .font(.system(size: 18))
            .fontWeight(.bold)
            .opacity(value.highlight ? 0.6 : 0.3)
            .foregroundStyle(Color.deepPurple)

            Spacer()
            Divider()
                .background(Color.deepPurple)
            Spacer()

            Text(
                value.duration
            )
            .font(.system(size: 16))
            .fontWeight(.bold)
            .opacity(0.3)
            .foregroundStyle(Color.deepPurple)

            Spacer()
        }
        .padding(8)
        .background(Color.lightPurple)
        .cornerRadius(8)
    }
    
    private func sleepValueCell(
        _ value: SleepSessionSummaryValue
    ) -> some View {
        
        return titleValueCell(
            title: value.titleString ?? "",
            titleColor: value.highlightAll ? viewModel.sleepColor : value.highlightValue ? viewModel.sleepColor : .gray,
            value: value.valueString ?? "",
            valueColor: value.highlightAll ? .black.opacity(0.8) : .black.opacity(0.5),
            highlighted: value.highlightAll,
            highlightedColor: .white
        )
    }
    
    private func hrvCell(
        _ entry: HRVEntryTableValue
    ) -> some View {
        
        return titleValueCell(
            title: entry.date,
            value: entry.value,
            valueColor: viewModel.heartColor
        )
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

    // MARK: Cards
    @ViewBuilder
    private func sleepDataCard(
        _ values: SleepSessionDisplayValues
    ) -> some View {
        
        VStack {
            
            ContentCard(
                content:
                    VStack{
                        
                        titleValueCell(title: "Wake up time", value: values.wakeUpTime, valueColor: viewModel.sleepColor, highlighted: true, highlightedColor: .white)
                        titleValueCell(title: "Duration", value: values.sleepDuration, valueColor: viewModel.sleepColor, highlighted: true, highlightedColor: .white)
                        
                        Divider()
                            .padding(.vertical, 8)

                        contentCardHeader("Summary")
                        
                        ForEach(values.sessionValues, id: \.self) { value in
                            sleepValueCell(value)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)

                        contentCardHeader("Sleep Stages")
                        ForEach(values.stagesValues, id: \.self) { value in
                            sleepSegmentCell(value)
                        }
                    }
            )
        }
    }
    
    @ViewBuilder
    private func tripInfoCard() -> some View {
        
        ContentCard(
            content:
                
                VStack {
                    
                    if viewModel.canStartTrip {
                        HStack {
                            if viewModel.currentTrip.activityStatus == .running {
                                Image(systemName: "car.fill")
                            }

                            Text(
                                viewModel.tripMessage
                            )
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.tripMessageColor)

                        if viewModel.currentTrip.activityStatus != .idle {
                            titleValueCell(
                                title: "Trip start",
                                value: viewModel.tripValues.startDate
                            )
                            
                            Divider()

                            titleValueCell(
                                title: "Last sleep duration",
                                value: viewModel.lastSleepSessionValues.sleepDuration
                            )
                            
                            Divider()

                            Text(
                                "formula: last_sleep_duration / 60"
                            )
                            .opacity(0.4)
                            
                            titleValueCell(
                                title: "",
                                value: "\(viewModel.lastSleepSessionValues.sleepDuration) / 60 = \(viewModel.tripValues.intervalUntilRest)"
                            )
                            
                            titleValueCell(
                                title: "Driving time before rest",
                                value: "\(viewModel.tripValues.intervalUntilRest)",
                                valueColor: .white,
                                highlighted: true,
                                highlightedColor: .teal
                            )
                            
                            Text(
                                "Rest should start \(viewModel.tripValues.intervalUntilRest) after the trip started."
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            
                            
                            Divider()

                            titleValueCell(
                                title: "Trip elapsed time",
                                value: viewModel.tripValues.elapsedTime
                            )

                            titleValueCell(
                                title: "Current date",
                                value: Date().dateTimeString(withFormat: .readableMilitary)
                            )

                            Divider()

                            titleValueCell(
                                title: "Rest should start in",
                                value: viewModel.tripValues.realTimeIntervalUntilRest
                            )
                            
                            titleValueCell(
                                title: "Rest date",
                                value: viewModel.tripValues.restDate
                            )
                        }
                        
                        HStack {
                            Spacer()

                            Button {
                                viewModel.toggleTrip()
                            } label: {
                                Label(
                                    viewModel.tripActionButtonText,
                                    systemImage: viewModel.currentTrip.activityStatus == .running
                                    ? "stop.fill"
                                    : viewModel.currentTrip.activityStatus == .completed 
                                    ? "bed.double.fill" : "play.fill"
                                )
                                .padding()
                            }
                            .modifier(ButtonCapsuleStyle(backgroundColor: viewModel.tripActionButtonBackground))

                            Spacer()
                        }
                    } else {
                        
                        Text(
                            "No sleep data available to start a new trip"
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .opacity(0.5)
                    }
                }
        )
    }
}

#Preview {
   HealthDataView()
}
