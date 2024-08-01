//
//  SleepDataView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import SwiftUI

struct ContentCard<T: View>: View {
    
    let title: String
    var color: Color?
    let content: T
    
    var body: some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(color ?? .black)
                .padding(.bottom, 32)
            
            content
        }
        .padding(24)
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
                            
                            sectionHeader(title: "Sleep")
                            
                            ContentCard(
                                title: "Longest sleep session",
                                content:
                                    VStack{
                                        ForEach(viewModel.sleepValues, id: \.self) { value in
                                            sleepValueCell(value)
                                        }
                                    }
                            )
                            
                            ContentCard(
                                title: "Raw sleep stages",
                                content:
                                    VStack{
                                        ForEach(viewModel.sleepSegments, id: \.self) { value in
                                            sleepSegmentCell(value)
                                        }
                                    }
                            )
                            
                            sectionHeader(title: "Heart")
                            
                            ContentCard(
                                title: "HRV",
                                content:
                                    VStack{
                                        ForEach(viewModel.hrvTableValues, id: \.self) { value in
                                            hrvCell(value)
                                        }
                                        titleValueCell(
                                            title: "Average",
                                            titleColor: viewModel.heartColor,
                                            value: String(format: "%.2f", viewModel.hrvAverage),
                                            valueColor: .white,
                                            highlighted: true,
                                            highlightedColor: viewModel.heartColor
                                        )
                                    }
                            )
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
    private func sleepSegmentCell(
        _ value: SleepSegmentTableValue
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
        _ value: SleepSessionTableValue
    ) -> some View {
        
        return titleValueCell(
            title: value.titleString ?? "",
            titleColor: value.highlightAll ? viewModel.sleepColor : value.highlightValue ? viewModel.sleepColor : .gray,
            value: value.valueString ?? "",
            valueColor: value.highlightAll ? .white : .black,
            highlighted: value.highlightAll,
            highlightedColor: viewModel.sleepColor
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
        title: "Sleep analysis",
        color: Color.purple,
        content:
                    HStack{}
        .frame(height: 100)
    )
}
