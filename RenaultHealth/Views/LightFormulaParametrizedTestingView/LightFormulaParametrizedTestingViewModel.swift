//
//  LightFormulaParametrizedTestingViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import Foundation
import SwiftUI

class LightFormulaParametrizedTestingViewModel: ObservableObject {
    @Published var test: String = ""
    
    @Published var decayConstant: String = ""
    @Published var lowAsymptote: String = ""
    @Published var decayConstantDriving: String = ""
    
    @Published var initialSleepPressure: String = ""
    @Published var circadianAmplitude: String = ""
    @Published var circadianAcrophase: String = ""
    @Published var maxSafetyTime: String = ""
    
    @Published var wakeupHourToday: String = ""

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
        self.wakeupHourToday = "\(defaultValues.wakeupHourToday)"
    }
    
    func calculateLightFormula() {
        
        let formula = LightFormula(
            parameters:
                LightFormulaParameters(
                    decayConstant: Double(decayConstant) ?? 0,
                    lowAsymptote: Double(lowAsymptote) ?? 0,
                    decayConstantDriving: Double(decayConstantDriving) ?? 0,
                    initialSleepPressure: Double(initialSleepPressure) ?? 0,
                    circadianAmplitude: Double(circadianAmplitude) ?? 0,
                    circadianAcrophase: Double(circadianAcrophase) ?? 0,
                    maxSafetyTime: Double(maxSafetyTime) ?? 0,
                    wakeupHourToday: Double(wakeupHourToday) ?? 0
                )
        )
        let res = formula.runDemonstration()
        print("calculateLightFormula results: \(res as AnyObject)")
    }
}
