//
//  SleepDataView.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import SwiftUI
import SleepSDK

struct SleepDataView: View {
    
    @StateObject private var viewModel = SleepDataViewModel()
    
    var body: some View {
        
        VStack {
            
            mainHeader()
            
            if !viewModel.isRefreshing {
                VStack{
                    ScrollView {
                        VStack {
                            sectionHeader(
                                title: "Longest Sleep Session"
                            )
                            
                            ForEach(viewModel.sleepValues, id: \.self) { value in
                                sleepValueCell(value)
                            }
                            
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .opacity(0.2)
                                .padding(.horizontal,8)
                            
                            sectionHeader(
                                title: "Raw segments"
                            )
                            
                            ForEach(viewModel.sleepSegments, id: \.self) { value in
                                sleepSegmentCell(value)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .refreshable {
                        viewModel.fetchSleepData()
                    }
                }
            } else {
                ZStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                }
            }
            
            Spacer()
        }
        
        //.padding(.horizontal,8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            viewModel.setUp()
        }
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
                    viewModel.fetchSleepData()
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
        .background(.purple)
    }
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        HStack{
            Text (
                title
            )
            .font(.title)
            .foregroundColor(.purple)
            
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
            
            Rectangle()
                .frame(maxHeight: .infinity)
                .frame(width: 1)
                .foregroundColor(.purple)
            
            VStack {
                Text(
                    value.start
                )
                Spacer()
                    .frame(height: 8)
                Text(
                    value.end
                )
            }
            
            Rectangle()
                .frame(maxHeight: .infinity)
                .frame(width: 1)
                .foregroundColor(.purple)
            
            Text(
                value.duration
            )
        }
        .padding(.vertical, 8)
    }
    
    private func sleepValueCell(
        _ value: SleepSessionTableValue
    ) -> some View {
        
        HStack{
            Text(value.titleString ?? "")
                .fontWeight(.bold)
                .foregroundColor(
                    value.highlightAll ? .purple : value.highlightValue ? .purple : .black
                )
                .font(Font.system(size: 14))
            Spacer()
            Text(value.valueString ?? "")
                .padding(8)
                .font(Font.system(size: 14))
                .foregroundColor(
                    value.highlightAll ? .white : .black
                )
                .background(
                    value.highlightAll ? .purple : .white
                )
                .cornerRadius(8)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SleepDataView()
}
