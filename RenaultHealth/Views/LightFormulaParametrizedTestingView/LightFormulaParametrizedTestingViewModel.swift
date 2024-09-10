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
    @Published var sleepDurations: [String] = ["8", "8", "8", "8", "8", "8", "8"]
    
//    @Published var sleepDurations: [Double] = [8, 8, 8, 8, 8, 8, 8]
    
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
    
    func resetAllSleepHistoryTo(value: TimeInterval) {
        
        for i in 0 ..< sleepDurations.count {
            sleepDurations[i] = "\(value)"
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
        
        TripDurationCalculator().fetchSleepHistory(
            to: Date()
        ) { durations in
            
            DispatchQueue.main.async {
                self.sleepDurations = durations.map{
                    String(format: "%.2f", $0)
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
        
        let sleepHistory = sleepDurations.map {
            Double($0) ?? 0
        }
        
        var res: [Int: Double] = [:]
        for currentTime in startTimes {
            res[currentTime] = lightFormula.calculateSafeDrivingTime(
                lastSleepHours: sleepHistory,
                hoursAwake: currentTime - wakeUpHour,
                currentHour: currentTime
            )
        }
        
        // Parse results for display
        self.results = res.map{ key, value in
            LightFormulaParametrizedResultItem(
                dayNumber: key,
                title: "\(key)",
                value: String(format: "%.2f", value / 3600),
                color: value > 6 ? .green : value > 4 ? .orange : value == 0 ? .red : .yellow
            )
        }.sorted(by: { $0.dayNumber < $1.dayNumber })
        
        print("calculateLightFormula results: \(res as AnyObject)")
        print("calculateLightFormula results: \(results as AnyObject)")
    }
}
