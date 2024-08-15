//
//  SleepDataViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import Foundation
import SwiftUI
import SleepSDK
import Combine

struct HRVEntryTableValue: Hashable {
    var date: String = ""
    var value: String = ""
    var isHighlighted: Bool = false
}

struct TripPrettyPrintValues {
    var startDate: String = ""
    var restDate: String = ""
    var elapsedTime: String  = ""
    var intervalUntilRest = ""
    var realTimeIntervalUntilRest = ""
}

class HealthDataViewModel: ObservableObject {
    
    let sleepColor: Color = .mint
    let heartColor: Color = Color(red: 255/255, green: 89/255, blue: 94/255)

    @Published var isRefreshing: Bool = true

    // Sleep
    @Published var lastSleepSessionValues: SleepSessionDisplayValues = SleepSessionDisplayValues()
    @Published var longestSleepSessionValues: SleepSessionDisplayValues = SleepSessionDisplayValues()
    @Published var allSleepSessionValues: [SleepSessionDisplayValues] = []
    
    // Heart
    @Published var hrvTableValues: [HRVEntryTableValue] = []
    @Published var hrvAverage: Double = 0
    
    // Trip
    @Published var currentTrip: Trip = Trip()
    @Published var tripMessage: String = "New Trip"
    @Published var tripMessageColor: Color = .black.opacity(0.4)
    @Published var tripActionButtonText: String = "Start"
    @Published var tripActionButtonBackground: Color = .mint
    @Published var tripValues: TripPrettyPrintValues = TripPrettyPrintValues()
    @Published var canStartTrip: Bool = false
    
    // Managers
    private var authorizationManager = HKAuthorizationManager()

    // DataSources
    private var sleepDataSource = HKSleepDataSource()
    private var heartDataSource = HKHeartDataSource()
    
    private let healthDataProvider = HealthDataProviderQA()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Permissions
    
    func requestHKPermission() {
        healthDataProvider.requestHealthKitPermission()
        healthDataProvider.requestAuthorizationCompleted
            .sink { _ in
                self.setupSleepBinding()
                print("Sleep binding enabled!")

            }.store(in: &cancellables)
    }
    

    // MARK: - Data
    func refreshData() {
        healthDataProvider.refreshData()
    }

    // MARK: - Bindings
    private func setupSleepBinding() {
        healthDataProvider.sleepSessionData
            .sink { data in
                self.parseSleepSessions(data)
                self.canStartTrip = data.lastSession != nil

            }.store(in: &cancellables)

        healthDataProvider.isRefreshing
            .sink { loading in
                self.isRefreshing = loading

            }.store(in: &cancellables)

        healthDataProvider.refreshData()
    }
    
    // MARK: - Sleep
    /*
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
                
                self.canStartTrip = self.sleepDataSource.lastSleepSession != nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0..<3)) {
                    self.isRefreshing = false
                }
            }
        }
    }
     */
    
    private func parseSleepSessions(_ data: SleepSessions) {
        // * Longest session
        if let longest = data.longestSession {
            self.longestSleepSessionValues = SleepSessionDisplayValues(
                sessionValues: longest.summaryInfo.compactMap {
                    SleepSessionSummaryValue(
                        titleString: $0.title,
                        valueString: $0.value,
                        highlightValue: $0.highlightValue,
                        highlightAll: $0.highlightAll
                    )
                },
                stagesValues: longest.segments.map {
                    SleepStageDisplayValues(
                        title: $0.info.title,
                        start: $0.info.start,
                        end: $0.info.end,
                        duration: $0.info.duration)
                },
                sleepDuration: longest.totalSleepDuration.verboseTimeString(),
                wakeUpTime: longest.endDate?.string(withFormat: .readable) ?? "none"
            )
        }
        
        // * Last session
        if let latest = data.lastSession {
            self.lastSleepSessionValues = SleepSessionDisplayValues(
                sessionValues: latest.summaryInfo.compactMap {
                    SleepSessionSummaryValue(
                        titleString: $0.title,
                        valueString: $0.value,
                        highlightValue: $0.highlightValue,
                        highlightAll: $0.highlightAll
                    )
                },
                stagesValues: latest.segments.map {
                    SleepStageDisplayValues(
                        title: $0.info.title,
                        start: $0.info.start,
                        end: $0.info.end,
                        duration: $0.info.duration)
                },
                sleepDuration: latest.totalSleepDuration.verboseTimeString(),
                wakeUpTime: latest.endDate?.string(withFormat: .readable) ?? "none"
            )
        }

        // * All sessions
        self.allSleepSessionValues = data.allSessions.compactMap { session in
            SleepSessionDisplayValues(
                sessionValues: session.summaryInfo.compactMap {
                    SleepSessionSummaryValue(
                        titleString: $0.title,
                        valueString: $0.value,
                        highlightValue: $0.highlightValue,
                        highlightAll: $0.highlightAll
                    )
                },
                stagesValues: session.segments.map {
                    SleepStageDisplayValues(
                        title: $0.info.title,
                        start: $0.info.start,
                        end: $0.info.end,
                        duration: $0.info.duration)
                },
                sleepDuration: session.totalSleepDuration.verboseTimeString(),
                wakeUpTime: session.endDate?.string(withFormat: .readable) ?? "none"
            )
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

    private func refreshTripInfo() {
        self.tripValues = TripPrettyPrintValues(
            startDate: self.currentTrip.startDatePretty,
            restDate: self.currentTrip.restDatePretty,
            elapsedTime: self.currentTrip.elapsedTimePretty,
            intervalUntilRest: self.currentTrip.intervalUntilRestPretty,
            realTimeIntervalUntilRest: self.currentTrip.realTimeIntervalUntilRestPretty
        )

        refreshTripPublishedValues()
    }

    private func refreshTripPublishedValues() {
        switch currentTrip.activityStatus {
        case .running:
            tripActionButtonText = "Stop"
            tripActionButtonBackground = .red
            tripMessage = "Running trip"
            tripMessageColor = .orange

        case .completed:
            tripActionButtonText = "Rest Now!"
            tripActionButtonBackground = .blue
            tripMessage = "Rest now!"
            tripMessageColor = .red

        case .idle:
            tripActionButtonText = "Start"
            tripActionButtonBackground = .mint
            tripMessage = "New Trip"
            tripMessageColor = .black.opacity(0.4)
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
    
    private func startTrip() {
        guard 
            let lastSleepSession = sleepDataSource.lastSleepSession
        else {
            return
        }

        currentTrip.start(lastSleepSession: lastSleepSession) { [weak self] _ in
            self?.refreshTripInfo()

        } restMustStart: { [weak self] in
            self?.refreshTripInfo()
        }
    }
    
    private func stopTrip() {
        self.currentTrip.reset()
    }
}
