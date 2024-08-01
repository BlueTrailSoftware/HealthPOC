//
//  AvailableHKIdentifiers.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 29/07/24.
//

import Foundation
import HealthKit

/// Provides the HK identifiers for each of the relevant HK data to retrieve
class AvailableHKIdentifiers: NSObject {
    
    /// All HealthKit sleep identifiers used by the app
    static let sleepIdentifiers: [HKCategoryTypeIdentifier] = [
        .sleepAnalysis
    ]
    
    /// All HealthKit heart identifiers used by the app
    static let heartIdentifiers: [HKQuantityTypeIdentifier] = [
        .heartRateVariabilitySDNN
    ]
}

