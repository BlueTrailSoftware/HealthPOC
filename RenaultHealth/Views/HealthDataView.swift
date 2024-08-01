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
                            
                            ContentCard(
                                title: "Longest sleep session",
                                color: viewModel.sleepColor,
                                content:
                                    VStack{
                                        ForEach(viewModel.sleepValues, id: \.self) { value in
                                            sleepValueCell(value)
                                        }
                                    }
                            )
                            
                            ContentCard(
                                title: "Raw sleep stages",
                                color: viewModel.sleepColor,
                                content:
                                    VStack{
                                        ForEach(viewModel.sleepSegments, id: \.self) { value in
                                            sleepSegmentCell(value)
                                        }
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
                "Sleep Data"
            )
            .foregroundColor(.white)
            .font(.title2)
            
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
            .font(.title2)
            .foregroundColor(.black)
            
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
        
        HStack{
            
            Text(value.titleString ?? "")
                .foregroundColor(
                    value.highlightAll ? viewModel.sleepColor : value.highlightValue ? viewModel.sleepColor : .gray
                )
                .font(Font.system(size: 16))
            
            Spacer()
            
            Text(value.valueString ?? "")
                .padding(8)
                .font(Font.system(size: 14))
                .opacity(value.highlightAll ? 1 : 0.6)
                .fontWeight(.bold)
                .foregroundColor(
                    value.highlightAll ? .white : .black
                )
                .background(
                    value.highlightAll ? viewModel.sleepColor : .white
                )
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
