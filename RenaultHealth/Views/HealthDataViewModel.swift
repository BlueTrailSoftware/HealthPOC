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

class HealthDataViewModel: ObservableObject {
    
    let sleepColor: Color = .mint
    let heartColor: Color = Color(red: 255/255, green: 89/255, blue: 94/255)
    
    @Published var isRefreshing: Bool = false
    
    // Sleep
    @Published var lastSleepSessionValues: SleepSessionDisplayValues = SleepSessionDisplayValues()
    @Published var longestSleepSessionValues: SleepSessionDisplayValues = SleepSessionDisplayValues()
    @Published var allSleepSessionValues: [SleepSessionDisplayValues] = []
    
    // Heart
    @Published var hrvTableValues: [HRVEntryTableValue] = []
    @Published var hrvAverage: Double = 0
    
    // Trip
    @Published var currentTrip: Trip = Trip()
    @Published var tripMessage: String = "Start a new trip"
    @Published var tripActionButtonText: String = "Start trip"
    @Published var tripActionButtonBackground: Color = .mint
    
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

                self.longestSleepSessionValues = self.sleepDataSource.longestSleepSession?.displayValues ?? SleepSessionDisplayValues()
                self.lastSleepSessionValues = self.sleepDataSource.lastSleepSession?.displayValues ?? SleepSessionDisplayValues()
                
                let allSessions = self.sleepDataSource.allSleepSessions
                self.allSleepSessionValues = allSessions.compactMap { session in
                    session.displayValues
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
    
    // MARK: - Trip
    
    func refreshTripPublishedValues() {
        switch currentTrip.activityStatus {
        case .running:
            tripActionButtonText = "Stop"
            tripActionButtonBackground = .red
            tripMessage = "Running trip"
        case .completed:
            tripActionButtonText = "Done"
            tripActionButtonBackground = .blue
            tripMessage = "Trip completed!"
        case .idle:
            tripActionButtonText = "Start Trip"
            tripActionButtonBackground = .mint
            tripMessage = "Start a new trip"
        }
    }
    
    func toggleTrip() {
        if currentTrip.activityStatus == .idle {
            startTrip()
        } else {
            stopTrip()
        }
        
        refreshTripPublishedValues()
    }
    
    func startTrip() {
        
        guard 
            let lastSleepSession = sleepDataSource.lastSleepSession
        else {
            return
        }
        
        currentTrip.start(
            lastSleepSession: lastSleepSession
        )
    }
    
    func stopTrip() {
        self.currentTrip.reset()
    }
}
