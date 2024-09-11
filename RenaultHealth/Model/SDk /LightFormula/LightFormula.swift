//
//  LightFormula.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 20/08/24.
//

import Foundation
import SwiftUI

// MARK: - Parameters

struct LightFormulaParameters {
    var decayConstant: Double = 0.1
    var lowAsymptote: Double = 2.4
    var decayConstantDriving: Double = 0.3
    
    var initialSleepPressure: Double = 14
    var circadianAmplitude: Double = 2.5
    var circadianAcrophase: Double = 16.48
    var maxSafetyTime: Double = 8
}

// MARK: - Light formula

class LightFormula {
    
    let parameters: LightFormulaParameters
    let sleepDebtSmooth: [Double] = [1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    
    // MARK: - Init
    
    init() {
        self.parameters = LightFormulaParameters()
    }
    
    init(parameters: LightFormulaParameters) {
        self.parameters = parameters
    }
    
    // MARK: - Safe driving time
    
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
    
    // MARK: - Calculations
    
    // Smooth factor for sleep debt in a given night from today (0 = last night))
    func sleepSmooth(
        xNightsAgo: Int
    ) -> Double {
        return xNightsAgo > 6 ? sleepDebtSmooth[6] : sleepDebtSmooth[xNightsAgo]
    }
    
    // Sleep debt for a given sleep duration history
    func calculateSleepDebt(sleepData: [Double], optimalSleep: Double = 8) -> Double {
        var sleepDebt = 0.0
        for (index, sleep) in sleepData.enumerated() {
            sleepDebt += (optimalSleep - sleep) * sleepDebtSmooth[sleepData.count - 1 - index]
        }
        return sleepDebt
    }
    
    func predictAlertness(
        hoursAwake: Double,
        sleepDebt: Double,
        currentHour: Double
    ) -> Double {
        let sProcess = (Double(parameters.initialSleepPressure) - parameters.lowAsymptote) * exp(-parameters.decayConstant * hoursAwake) + parameters.lowAsymptote
        let circadian = parameters.circadianAmplitude * cos(2 * .pi * (currentHour - parameters.circadianAcrophase) / 24)
        return sProcess + circadian - sleepDebt
    }
    
    // time before a rest is needed
    // Result is resturned in seconds
    func timeBeforeTired(
        alertnessLevel: Double,
        threshold: Double = 5
    ) -> Double {
        if alertnessLevel <= threshold {
            return 0
        }
        let remainingTime = (alertnessLevel - threshold) / parameters.decayConstantDriving
        return min(max(remainingTime, 0), Double(parameters.maxSafetyTime)) * 3600
    }
}
