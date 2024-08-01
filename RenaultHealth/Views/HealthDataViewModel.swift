//
//  SleepDataViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import Foundation
import SwiftUI

struct SleepSegmentTableValue: Hashable {
    var title: String = ""
    var start: String = ""
    var end: String = ""
    var duration: String = ""
}

struct HRVEntryTableValue: Hashable {
    var date: String = ""
    var value: String = ""
    var isHighlighted: Bool = false
}

class HealthDataViewModel: ObservableObject {
    
    let sleepColor: Color = .mint
    
    @Published var isRefreshing: Bool = false
    
    // Sleep
    @Published var sleepValues: [SleepSessionTableValue] = []
    @Published var sleepSegments: [SleepSegmentTableValue] = []
    
    // Heart
    @Published var hrvTableValues: [HRVEntryTableValue] = []
    @Published var hrvAverage: Double = 0
    
    // DataSources
    private var sleepDataSource = HKSleepDataSource()
    private var heartDataSource = HKHeartDataSource()
    
    func requestHKPermission() {
        HKAuthorizationManager().requestPermissions()
    }
    
    func refreshData() {
        fetchSleepSegments()
        fetchHRV()
    }
    
    // MARK: - Sleep
    
    private func fetchSleepSegments() {
        
        DispatchQueue.main.async {
            self.isRefreshing = true
        }
        
        sleepDataSource.fetchLongestSleepSession(for: Date()) { session in
            
            print("fetchLongestSleepSession : ", session?.startingDate ?? 0 ," ::: ",session?.endDate ?? 0)
            session?.tableValues.forEach({ value in
                print("tableValue : ", value.titleString ?? "no" ," ::: ", value.valueString ?? "no", " ::: ", value.highlightValue, " ::: ", value.highlightAll)
                print("tableValue: segments : ", session?.segments ?? [])
            })
            
            DispatchQueue.main.async {
                self.isRefreshing = false
                self.sleepValues = session?.tableValues ?? []
                
                // Raw sleep segments
                if let segments = session?.segments {
                    self.sleepSegments = segments.map{ segment in
                        SleepSegmentTableValue(
                            title: HKSleepProperties.displayName(sleepSegmentType: segment.sleepAnalysis ?? .asleepUnspecified) ?? "unknown" ,
                            start: segment.startDate.string(withFormat: StringDateFormat.readable),
                            end: segment.endDate.string(withFormat: StringDateFormat.readable),
                            duration: DateIntervalCalculations.calculateTotalDuration(
                                for: [
                                    DateInterval(
                                        start: segment.startDate,
                                        end: segment.endDate
                                    )
                                ]
                            ).verboseTimeString()
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Heart
    
    private func fetchHRV() {
        heartDataSource.fetchHRV(
            from: Date().startOfDay,
            to: Date().endOfDay
        ) { entries in
        
            DispatchQueue.main.async {
                
                guard let entries = entries else {
                    self.hrvTableValues = []
                    self.hrvAverage = 0
                    return
                }
                
                self.hrvTableValues = entries.map{ entry in
                    HRVEntryTableValue(
                        date: entry.startDate.string(withFormat: .readable),
                        value: "\(entry.value)",
                        isHighlighted: false
                    )
                }
                self.hrvAverage = entries.map { $0.value }.reduce(0, +)
            }
        }
    }
}
