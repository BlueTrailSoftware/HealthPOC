//
//  SDKEngine.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 13/08/24.
//

import Foundation

enum DaciaHealthError {
    case emptyDataOrPermissionsNotGranted
    case notEnoughSleepHistoryToCalculate
    case errorCalculatingTripDuration
    case noLastAwakeDateFound
    case intervalSinceLastAwakeDateIsNegative
    case couldNotCalculateHoursAwake
}

class TripDurationCalculator {
    
    private var sleepDataSource = HKSleepDataSource()
    private var onError: ((DaciaHealthError) -> Void)?
    
    // MARK: - Permissions
    
    // Entry point
    func runCalculation(
        onResult: ((Double) -> Void)?,
        onError: ((DaciaHealthError) -> Void)?
    ) {
        
        self.onError = onError
        
        // 1. Sleep for the previous weeks
        fetchSleepHistoryFromHK { sleepHistory in
            
            // No sleep data could be fetched
            // NOTE: This could mean no HealthKit permissions have been granted so the HK data is unacessible.
            if sleepHistory.isEmpty {
                onError?(.emptyDataOrPermissionsNotGranted)
                return
            }
            
            // Not enough sleep sessions available
            if sleepHistory.count != 7 {
                onError?(.notEnoughSleepHistoryToCalculate)
                return
            }
            
            guard let lightFormulaResult = self.calculateLightFormula(
                startDate: Date(),
                sleepHistory: sleepHistory
            ) else {
                onError?(.errorCalculatingTripDuration)
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
            self.onError?(.noLastAwakeDateFound)
            return nil
        }
        
        let intervalSinceLastSleep = currentDate.timeIntervalSince(lastAwakeDate)
        if intervalSinceLastSleep < 0 {
            self.onError?(.intervalSinceLastAwakeDateIsNegative)
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
            self.onError?(.couldNotCalculateHoursAwake)
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
