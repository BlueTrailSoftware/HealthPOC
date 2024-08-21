//
//  LightFormula.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 20/08/24.
//

import Foundation
import SwiftUI

class LightFormula {
    
    // Constants
    let DECAY_CONSTANT = 0.1
    let LOW_ASYMPTOTE = 2.4
    let DECAY_CONSTANT_DRIVING = 0.3
    
    // Global vars
    let initialSleepPressure = 14
    let circadianAmplitude = 2.5
    let circadianAcrophase = 16.48
    let maxSafetyTime = 8

    let vWakeupHourToday = 7
    let sleepDebtSmooth: [Double] = [1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    let tripStartTimes: [Int] = [7, 9, 11, 13, 15, 17, 19, 21, 23]
    
    // MARK: - Calculation
    
    // Function to calculate safe driving
    func calculateSafeDrivingTime(
        lastSleepHours: [Double],
        hoursAwake: Int,
        currentHour: Int
    ) -> Double {
        
        let sleepDebt = calculateSleepDebt(sleepData: lastSleepHours)
        let alertnessLevel = predictAlertness(
            hoursAwake: Double(hoursAwake),
            sleepDebt: sleepDebt,
            currentHour: Double(currentHour)
        )
        let remainingTime = timeBeforeTired(alertnessLevel: alertnessLevel)
        return remainingTime
    }
    
    // MARK: - Parameters
    
    // Different sets of sleep data for the week, groing from 0 to 10 hours of sleep every day
    func testSleepDataSet() -> [String: [Double]] {
        
        var sleepDataSets = [String: [Double]]()
        let idealSleep = [8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0]
        
        sleepDataSets["\(idealSleep)"] = idealSleep
        
        // Add constant sleep rate
        for i in 0...10 {
            let sleepData = Array(repeating: Double(i), count: 7)
            sleepDataSets["\(sleepData)"] = sleepData
        }
        
        // Add decreasing one night
        for i in (0...6).reversed() {
            for j in (0...7).reversed() {
                var sleep = idealSleep
                sleep[i] = Double(j)
                sleepDataSets["\(sleep) one day"] = sleep
            }
        }
        
        // Add first nights with x sleep
        for i in 0...2 {
            for j in 0...4 {
                var sleep = idealSleep
                for k in 0...i {
                    sleep[k] = 8 - Double(j * 2)
                }
                sleepDataSets["\(sleep)"] = sleep
            }
        }
        
        // Adding custom cases
        sleepDataSets["[8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 6.0]"] = [8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 6.0]
        sleepDataSets["[8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 4.0]"] = [8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 4.0]
        sleepDataSets["[8.0, 8.0, 8.0, 8.0, 8.0, 4.0, 4.0]"] = [8.0, 8.0, 8.0, 8.0, 8.0, 4.0, 4.0]
        sleepDataSets["[8.0, 8.0, 8.0, 8.0, 8.0, 7.0, 7.0]"] = [8.0, 8.0, 8.0, 8.0, 8.0, 7.0, 7.0]
        sleepDataSets["[8.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0]"] = [8.0, 8.0, 8.0, 8.0, 8.0, 7.0, 6.0]
        sleepDataSets["[8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 7.0]"] = [8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 7.0]
        
        return sleepDataSets
    }
    
    // MARK: - Demonstration
    
    // Smooth factor for sleep debt in a given night from today (0 = last night))
    func sleepSmooth(
        xNightsAgo: Int
    ) -> Double {
        return xNightsAgo > 6 ? sleepDebtSmooth[6] : sleepDebtSmooth[xNightsAgo]
    }
    
    // Calculate the sleep debt based on the sleep data and a smooth factor
    func calculateSleepDebt(sleepData: [Double], optimalSleep: Double = 8) -> Double {
        var sleepDebt = 0.0
        for (index, sleep) in sleepData.enumerated() {
            sleepDebt += (optimalSleep - sleep) * sleepDebtSmooth[sleepData.count - 1 - index]
        }
        return sleepDebt
    }
    
    // Function to predict alertness
    func predictAlertness(
        hoursAwake: Double,
        sleepDebt: Double,
        currentHour: Double
    ) -> Double {
        let sProcess = (Double(initialSleepPressure) - LOW_ASYMPTOTE) * exp(-DECAY_CONSTANT * hoursAwake) + LOW_ASYMPTOTE
        let circadian = circadianAmplitude * cos(2 * .pi * (currentHour - circadianAcrophase) / 24)
        return sProcess + circadian - sleepDebt
    }
    
    // Function to calculate time before becoming tired
    func timeBeforeTired(alertnessLevel: Double, threshold: Double = 7) -> Double {
        if alertnessLevel <= threshold {
            return 0
        }
        let remainingTime = (alertnessLevel - threshold) / DECAY_CONSTANT_DRIVING
        return min(max(remainingTime, 0), Double(maxSafetyTime))
    }
    
    // Function to calculate safe driving
    func calculateSafeDriving(
        startTimes: [Int],
        sleepData: [Double]
    ) -> [Int: Double] {
        
        print("calculateSafeDriving_startTimes : \(startTimes)")
        
        var drivingCalc = [Int: Double]()
        for currentTime in startTimes {
            /*
            let hoursAwake = Double(currentTime - vWakeupHourToday)
            let sleepDebt = calculateSleepDebt(sleepData: sleepData)
            let alertnessLevel = predictAlertness(
                hoursAwake: hoursAwake,
                sleepDebt: sleepDebt,
                currentHour: Double(currentTime)
            )
            let remainingTime = timeBeforeTired(alertnessLevel: alertnessLevel)
            */
            drivingCalc[currentTime] = calculateSafeDrivingTime(
                lastSleepHours: sleepData,
                hoursAwake: currentTime - vWakeupHourToday,
                currentHour: currentTime
            )
        }
        return drivingCalc
    }
    
    // Example function to display a heatmap (conceptual, plotting not implemented)
    func runDemonstration() -> [String: [Int: Double]] {
        let sleepDataSets = testSleepDataSet()
        print("sleepDataSets : \(sleepDataSets as AnyObject)")
        
        var results: [String: [Int: Double]] = [:]
        
        for (label, sleepData) in sleepDataSets {
            let drivingCalc = calculateSafeDriving(startTimes: tripStartTimes, sleepData: sleepData)
            results[label] = drivingCalc
        }
        
        // Visualization would be done here using a Swift plotting library or exporting data
        // Since plotting in Swift directly isn't straightforward, we would usually use
        // libraries or frameworks to visualize the results.
        
        print("runDemonstration results: \(results as AnyObject)")
        
        return results
    }
    
    // Main entry point
    //showDefaultHeatmap()
}
