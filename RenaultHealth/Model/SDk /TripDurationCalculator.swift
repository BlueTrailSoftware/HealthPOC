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
        
        let date = Date()
        
        // 1. Sleep for the previous weeks
        fetchSleepHistory(
            to: date
        ) { sleepHistory in
            
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
    
    func fetchSleepHistory(
        to date: Date,
        completion: (([TimeInterval]) -> Void)?
    ) {
        
        sleepDataSource.fetchSleepSessions(
            from: date.modifyDateBy(days: -8),
            to: date
        ) {
            
            var durations: [TimeInterval] = []
            var upperDate: Date = date
            for _ in 0 ..< 7 {
                
                let lowerDate = upperDate.modifyDateBy(hours: -24)
                
                let dayDuration = self.sleepDataSource.totalSleepDuration(
                    within: lowerDate ... upperDate
                )
                durations.append(dayDuration / 3600)
                
                print("fetchSleepHistory : \(lowerDate) ::: \(upperDate) ::: \(dayDuration)")
                
                upperDate = lowerDate
            }
            
            DispatchQueue.main.async {
                completion?(durations.reversed())
            }
        }
    }
    
    // MARK: - Calculations
    
    func lastSignificantSession(
        currentDate: Date
    ) -> HKSleepSession? {
        return sleepDataSource.sessions(
            within: currentDate.modifyDateBy(hours: -24) ... currentDate
        ).sorted {
            $0.totalSleepDuration > $1.totalSleepDuration
        }.first
    }
    
    private func hoursAwake(
        currentDate: Date
    ) -> TimeInterval? {
        
        let lastSignificantSession = lastSignificantSession(
            currentDate: currentDate
        )
        
        guard
            let lastAwakeDate = lastSignificantSession?.endDate
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
    
    func calculateLightFormula(
        startDate: Date,
        sleepHistory: [TimeInterval]
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
