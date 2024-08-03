//
//  SleepDataViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import Foundation
import SwiftUI

struct HRVEntryTableValue: Hashable {
    var date: String = ""
    var value: String = ""
    var isHighlighted: Bool = false
}

struct SleepSessionValues: Hashable {
    var sessionValues: [SleepSessionDisplayValues] = []
    var stagesValues: [SleepStageDisplayValues] = []
    var sleepDuration: String = "0"
    var wakeUpTime: String = "none"
}

class HealthDataViewModel: ObservableObject {
    
    let sleepColor: Color = .mint
    let heartColor: Color = Color(red: 255/255, green: 89/255, blue: 94/255)
    
    @Published var isRefreshing: Bool = false
    
    // Sleep
    @Published var lastSleepSessionValues: SleepSessionValues = SleepSessionValues()
    @Published var longestSleepSessionValues: SleepSessionValues = SleepSessionValues()
    @Published var allSleepSessionValues: [SleepSessionValues] = []
    
    // Heart
    @Published var hrvTableValues: [HRVEntryTableValue] = []
    @Published var hrvAverage: Double = 0
    
    // DataSources
    private var sleepDataSource = HKSleepDataSource()
    private var heartDataSource = HKHeartDataSource()
    
    // MARK: - Permissions
    
    func requestHKPermission() {
        HKAuthorizationManager().requestPermissions()
    }
    
    //MARK: - Data
    
    func refreshData() {
        refreshSleepData()
    }
    
    // MARK: - Sleep
    
    private func refreshSleepData() {
        
        DispatchQueue.main.async {
            self.isRefreshing = true
        }
        
        sleepDataSource.refreshSleepSessions(for: Date()) {
            
            DispatchQueue.main.async {
                
                let longestSession = self.sleepDataSource.lastSleepSession
                self.longestSleepSessionValues = SleepSessionValues(
                    sessionValues: longestSession?.displayValues ?? [],
                    stagesValues: longestSession?.segments.map{ $0.tableValues } ?? [],
                    sleepDuration: (longestSession?.totalSleepDuration ?? 0).verboseTimeString(),
                    wakeUpTime: longestSession?.endDate?.string(withFormat: .readable) ?? "none"
                )
                
                let lastSession = self.sleepDataSource.lastSleepSession
                self.lastSleepSessionValues = SleepSessionValues(
                    sessionValues: lastSession?.displayValues ?? [],
                    stagesValues: lastSession?.segments.map{ $0.tableValues } ?? [],
                    sleepDuration: (lastSession?.totalSleepDuration ?? 0).verboseTimeString(),
                    wakeUpTime: lastSession?.endDate?.string(withFormat: .readable) ?? "none"
                )
                
                let allSessions = self.sleepDataSource.allSleepSessions
                self.allSleepSessionValues = allSessions.compactMap { session in
                    SleepSessionValues(
                        sessionValues: session.displayValues,
                        stagesValues: session.segments.map{ $0.tableValues },
                        sleepDuration: (session.totalSleepDuration).verboseTimeString(),
                        wakeUpTime: session.endDate?.string(withFormat: .readable) ?? "none"
                    )
                }
                
                self.isRefreshing = false
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
                self.hrvAverage = entries.map { $0.value }.reduce(0, +) / Double(entries.count)
            }
        }
    }
}
