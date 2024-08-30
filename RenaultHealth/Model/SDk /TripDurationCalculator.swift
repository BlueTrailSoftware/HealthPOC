//
//  SDKEngine.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 13/08/24.
//

import Foundation

enum TripDurationCalculatorError {
    case notEnoughDataToCalculate
}

class TripDurationCalculator {
    
    private var sleepDataSource = HKSleepDataSource()
    
    // MARK: - Permissions
    
    // Entry point
    func runCalculation(
        onResult: ((Double) -> Void)?,
        onError: ((TripDurationCalculatorError) -> Void)?
    ) {
        
        // 1. Sleep for the previous weeks
        fetchSleepHistoryFromHK { sleepHistory in
            
            /*
            if sleepHistory.count != 7 {
                onError?(.notEnoughDataToCalculate)
                return
            }
            */
            
            guard let lightFormulaResult = self.calculateLightFormula(
                startDate: Date(),
                sleepHistory: sleepHistory
            ) else {
                onError?(.notEnoughDataToCalculate)
                return
            }
            
            onResult?(lightFormulaResult)
        }
    }
    
    // MARK: - Healthkit
    
    private func fetchSleepHistoryFromHK(
        completion: (([Int]) -> Void)?
    ) {
        sleepDataSource.fetchSleepSessions(
            forPastDays: 8
        ) {
            DispatchQueue.main.async {
                let durations = self.sleepDataSource.lastSleepSessions(sessionCount: 7).map { Int($0.totalSleepDuration / 3600)}
                completion?(durations.reversed())
            }
        }
    }
    
    // MARK: - Calculations
    
    private func hoursAwake(
        currentDate: Date
    ) -> TimeInterval? {
        
        guard
            let lastAwakeDate = sleepDataSource.lastSleepSession?.endDate
        else {
            return nil
        }
        
        let intervalSinceLastSleep = currentDate.timeIntervalSince(lastAwakeDate)
        if intervalSinceLastSleep < 0 {
            return nil
        }
        
        return intervalSinceLastSleep / 3600
    }
    
    private func calculateLightFormula(
        startDate: Date,
        sleepHistory: [Int]
    ) -> Double? {
        
        // 2. hours awake
        guard let hoursAwake = hoursAwake(currentDate: startDate) else {
            return nil
        }
        
        // calculateSafeDriving
        let res = LightFormula(
            parameters: LightFormulaParameters()
        ).calculateSafeDrivingTime(
            lastSleepHours: sleepHistory.map{ Double($0)},
            hoursAwake: Int(hoursAwake),
            currentHour: startDate.hourOfDate
        )
        
        return res
    }
}
