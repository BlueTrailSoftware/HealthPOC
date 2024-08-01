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

class HealthDataViewModel: ObservableObject {
    
    let sleepColor: Color = .mint
    
    @Published var sleepValues: [SleepSessionTableValue] = []
    @Published var sleepSegments: [SleepSegmentTableValue] = []
    @Published var isRefreshing: Bool = false
    
    private var dataSource = HKSleepDataSource()
    private var hDataSource = HKHeartDataSource()
    
    func requestHKPermission() {
        HKAuthorizationManager().requestPermissions()
    }
    
    func refreshData() {
        fetchSleepSegments()
        fetchHRV()
    }
    
    private func fetchSleepSegments() {
        
        DispatchQueue.main.async {
            self.isRefreshing = true
        }
        
        dataSource.fetchLongestSleepSession(for: Date()) { session in
            
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
    
    private func fetchHRV() {
        hDataSource.fetchHRV(
            from: Date().startOfDay,
            to: Date().endOfDay,
            completion: nil
        )
    }
}
