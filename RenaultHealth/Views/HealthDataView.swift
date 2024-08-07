//
//  SleepDataView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import SwiftUI

struct ContentCard<T: View>: View {
    
    let content: T
    
    var body: some View {
        VStack {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(16)
    }
}

struct HealthDataView: View {
    
    @StateObject private var viewModel = HealthDataViewModel()
    
    var body: some View {
        
        VStack {
            
            if !viewModel.isRefreshing {
                VStack{
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
            } else {
                ZStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal,8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            viewModel.requestHKPermission()
            viewModel.refreshData()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple.opacity(0.8), .white]), startPoint: .top, endPoint: .bottom)
            )
    }
    
    @ViewBuilder
    private func mainHeader() -> some View {
        
        ZStack{
            
            Text(
                "Health Data"
            )
            .foregroundColor(.white)
            .font(.title2)
            .fontWeight(.bold)
            
            HStack{
                Spacer()
                
                Button {
                    viewModel.refreshData()
                } label: {
                    Text(
                        "Refresh"
                    )
                }
                .foregroundColor(.white)
                .background(.clear)
                .frame(height: 44)
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
    }
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        HStack{
            Text (
                title
            )
            .font(.system(size: 32))
            .fontWeight(.bold)
            .foregroundColor(.black.opacity(0.4))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
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
            .padding(.bottom, 24)
    }
    
    @ViewBuilder
    private func sleepSegmentCell(
        _ value: SleepStageDisplayValues
    ) -> some View {
        HStack{
            
            Text(
                value.title
            )
            .font(.system(size: 18))
            .fontWeight(.bold)
            .opacity(0.6)
            
            Rectangle()
                .frame(maxHeight: .infinity)
                .frame(width: 1)
                .foregroundColor(viewModel.sleepColor)
                .padding(.horizontal, 8)
            
            VStack {
                Text(
                    value.start
                )
                .opacity(0.6)
                
                Spacer()
                    .frame(height: 8)
                
                Text(
                    value.end
                )
                .opacity(0.6)
            }
            
            Rectangle()
                .frame(maxHeight: .infinity)
                .frame(width: 1)
                .foregroundColor(viewModel.sleepColor)
                .padding(.horizontal, 8)
            
            Text(
                value.duration
            )
            .font(.system(size: 16))
            .fontWeight(.bold)
            .opacity(0.6)
        }
        .padding(.vertical, 8)
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
    private func sleepDataCard(
        _ values: SleepSessionDisplayValues
    ) -> some View {
        
        VStack {
            
            ContentCard(
                content:
                    VStack{
                        
                        titleValueCell(title: "Wake up time", value: values.wakeUpTime, valueColor: viewModel.sleepColor, highlighted: true, highlightedColor: .white)
                        titleValueCell(title: "Duration", value: values.sleepDuration, valueColor: viewModel.sleepColor, highlighted: true, highlightedColor: .white)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(.vertical, 16)
                            .foregroundColor(.black.opacity(0.1))
                        
                        contentCardHeader("Summary")
                        
                        ForEach(values.sessionValues, id: \.self) { value in
                            sleepValueCell(value)
                        }
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(.vertical, 16)
                            .foregroundColor(.black.opacity(0.1))
                        
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
                    
                    Text(
                        viewModel.tripMessage
                    )
                    .font(.system(size: 22))
                    .foregroundColor(viewModel.tripMessageColor)
                    
                    if viewModel.currentTrip.activityStatus != .idle {
                        titleValueCell(
                            title: "Trip start",
                            value: viewModel.tripValues.startDate
                        )
                        
                        titleValueCell(
                            title: "Rest date",
                            value: viewModel.tripValues.restDate
                        )
                        
                        titleValueCell(
                            title: "Trip elapsed time",
                            value: viewModel.tripValues.elapsedTime
                        )
                        
                        titleValueCell(
                            title: "Rest coming in:",
                            value: viewModel.tripValues.intervalUntilRest
                        )
                    }
                    
                    Button {
                        viewModel.toggleTrip()
                    } label: {
                        Text(
                            viewModel.tripActionButtonText
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(viewModel.tripActionButtonBackground)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
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
                .font(Font.system(size: 16))
            
            Spacer()
            
            Text(value)
                .padding(8)
                .font(Font.system(size: 14))
                .fontWeight(.bold)
                .foregroundColor(valueColor)
                .background(highlighted ?? false ? highlightedColor : .white)
                .cornerRadius(8)
        }
        .frame(height: 44)
        .padding(.leading, 16)
    }
}

#Preview {
    ContentCard(
        content:
                    HStack{}
        .frame(height: 100)
    )
}
