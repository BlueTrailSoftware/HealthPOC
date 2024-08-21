//
//  LightFormulaParametrizedTestingViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 21/08/24.
//

import Foundation
import SwiftUI

class LightFormulaParametrizedTestingViewModel: ObservableObject {
    @Published var decayConstant: String = ""
    @Published var lowAsymptote: String = ""
    @Published var decayConstantDriving: String = ""
    
    @Published var initialSleepPressure: String = ""
    @Published var circadianAmplitude: String = ""
    @Published var circadianAcrophase: String = ""
    @Published var maxSafetyTime: String = ""
    
    @Published var wakeupHourToday: String = ""
}
