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
    @Published var wakeupHourToday: String = "7"
    @Published var sleepDurations: [String] = ["8", "8", "8", "8", "8", "8", "8"]
        
    @Published var lightFormulaResult: String = ""
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
        let sleepHistory = sleepDurations.map {
            Double($0) ?? 0
        }
        
        // calculateSafeDriving
        let currentTime = Date().hourOfDate
        let res = LightFormula(parameters: params).calculateSafeDrivingTime(
            lastSleepHours: sleepHistory,
            hoursAwake: currentTime - wakeUpHour,
            currentHour: currentTime
        )
        
        let (h,m,_) = secondsToHoursMinutesSeconds(Int(res))
        self.lightFormulaResult = "\(h) Hours, \(m) Minutes"
    }
    
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
