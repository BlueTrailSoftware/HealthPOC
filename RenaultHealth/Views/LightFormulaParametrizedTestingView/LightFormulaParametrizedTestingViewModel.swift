//
//  LightFormulaParametrizedTestingViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import Foundation
import SwiftUI


enum SleepHistorySource {
    case custom
    case healthkit
}

struct LightFormulaParametrizedResultItem: Hashable {
    var dayNumber: Int
    var title: String
    var value: String
    var color: Color
}

class LightFormulaParametrizedTestingViewModel: ObservableObject {
    @Published var test: String = ""
    
    @Published var decayConstant: String = ""
    @Published var lowAsymptote: String = ""
    @Published var decayConstantDriving: String = ""
    
    @Published var initialSleepPressure: String = ""
    @Published var circadianAmplitude: String = ""
    @Published var circadianAcrophase: String = ""
    @Published var maxSafetyTime: String = ""
    
    @Published var sleepHistorySource: SleepHistorySource = .custom {
        didSet {
            refreshSleepHistory()
        }
    }
    @Published var wakeupHourToday: String = ""
    @Published var sleepHoursInTheLastDays: [Int] = [8, 8, 8, 8, 8, 8, 8]
    
    @Published var results: [LightFormulaParametrizedResultItem] = []
    
    // HealthKit
    private var sleepDataSource = HKSleepDataSource()
    
    // MARK: - Values
    
    func resetAllValues() {
        resetConstants()
        resetSleepVars()
    }
    
    func resetConstants() {
        let defaultValues = LightFormulaParameters()
        
        self.decayConstant = "\(defaultValues.decayConstant)"
        self.lowAsymptote = "\(defaultValues.lowAsymptote)"
        self.decayConstantDriving = "\(defaultValues.decayConstantDriving)"
    }
    
    func resetSleepVars() {
    
        let defaultValues = LightFormulaParameters()
        
        self.initialSleepPressure = "\(defaultValues.initialSleepPressure)"
        self.circadianAmplitude = "\(defaultValues.circadianAmplitude)"
        self.circadianAcrophase = "\(defaultValues.circadianAcrophase)"
        self.maxSafetyTime = "\(defaultValues.maxSafetyTime)"
    }
    
    func resetSleepHistory() {
        resetAllSleepHistoryTo(value: 8)
    }
    
    func resetAllSleepHistoryTo(value: Int) {
        
        for i in 0 ..< sleepHoursInTheLastDays.count {
            sleepHoursInTheLastDays[i] = value
        }
    }
    
    // MARK: - Health kit data
    
    private func refreshSleepHistory() {
        
        switch sleepHistorySource {
        case .custom:
            resetSleepHistory()
        case .healthkit:
            fetchSleepHistoryFromHK()
        }
    }
    
    private func fetchSleepHistoryFromHK() {
        
        sleepDataSource.fetchSleepSessions(
            forPastDays: 7
        ) {
                
            DispatchQueue.main.async {
                
                let durations = self.sleepDataSource.lastSleepSessions(sessionCount: 7).map { Int($0.totalSleepDuration / 3600)
                }
                
                for i in 0 ..< self.sleepHoursInTheLastDays.count {   
                    let newValue = durations.count > i ? durations[i] : 0
                    self.sleepHoursInTheLastDays[self.sleepHoursInTheLastDays.count - 1 - i] = newValue
                }
            }
        }
    }
    
    // MARK: - Calculations
    
    func calculateLightFormula() {
        
        let params = LightFormulaParameters(
            decayConstant: Double(decayConstant) ?? 0,
            lowAsymptote: Double(lowAsymptote) ?? 0,
            decayConstantDriving: Double(decayConstantDriving) ?? 0,
            initialSleepPressure: Double(initialSleepPressure) ?? 0,
            circadianAmplitude: Double(circadianAmplitude) ?? 0,
            circadianAcrophase: Double(circadianAcrophase) ?? 0,
            maxSafetyTime: Double(maxSafetyTime) ?? 0
        )
        
        // Start times
        let wakeUpHour = Int(wakeupHourToday) ?? 7
        let startTimes: [Int] = [7, 9, 11, 13, 15, 17, 19, 21, 23].filter { i in
            i >= wakeUpHour
        }
        
        // calculateSafeDriving
        let lightFormula = LightFormula(parameters: params)
        
        var res: [Int: Double] = [:]
        for currentTime in startTimes {
            res[currentTime] = lightFormula.calculateSafeDrivingTime(
                lastSleepHours: sleepHoursInTheLastDays.map{ Double($0) },
                hoursAwake: currentTime - wakeUpHour,
                currentHour: currentTime
            )
        }
        
        // Parse results for display
        self.results = res.map{ key, value in
            LightFormulaParametrizedResultItem(
                dayNumber: key,
                title: "\(key)",
                value: String(format: "%.2f", value),
                color: value > 6 ? .green : value > 4 ? .orange : value == 0 ? .red : .yellow
            )
        }.sorted(by: { $0.dayNumber < $1.dayNumber })
        
        print("calculateLightFormula results: \(res as AnyObject)")
        print("calculateLightFormula results: \(results as AnyObject)")
    }
}
