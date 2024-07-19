//
//  HKSleepProperties.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation
import HealthKit

/// Contains the common properties for a HKCategoryValueSleepAnalysis value
class HKSleepProperties: NSObject {
    
    /// Display name for a HKCategoryValueSleepAnalysis value
    static func displayName(
        sleepSegmentType: HKCategoryValueSleepAnalysis
    ) -> String? {
        switch sleepSegmentType {
        case .inBed:
            return "in Bed"
        case .asleepUnspecified:
            return "Unspecified"
        case .asleep:
            return "Asleep"
        case .awake:
            return "Awake"
        case .asleepCore:
            return "Core"
        case .asleepDeep:
            return "Deep"
        case .asleepREM:
            return "REM"
        @unknown default:
            return "Unknown"
        }
    }
    
    /// String Ids for each HKCategoryValueSleepAnalysis value to be used when uploading the data to the server
    private static func stringIds() -> [HKCategoryValueSleepAnalysis: String] {
        
        var idsBySleepType: [HKCategoryValueSleepAnalysis: String] = [
            .inBed: "inBed",
            .asleepUnspecified: "asleep",
            .awake: "awake"
        ]
        
        if #available(iOS 16.0, *) {
            idsBySleepType[.asleepUnspecified] = "asleepUnspecified"
            idsBySleepType[.asleepCore] = "asleepCore"
            idsBySleepType[.asleepDeep] = "asleepDeep"
            idsBySleepType[.asleepREM] = "asleepREM"
        }
        
        return idsBySleepType
    }
    
    /// String Ids for a given HKCategoryValueSleepAnalysis value
    static func stringId(
        sleepSegmentType: HKCategoryValueSleepAnalysis
    ) -> String {
        stringIds()[sleepSegmentType] ?? ""
    }
    
    /// HKCategoryValueSleepAnalysis for a given String Id
    static func sleepSegmentType(
        with stringId: String
    ) -> HKCategoryValueSleepAnalysis? {
        
        let sleepType = stringIds().first { key, value in
            value == stringId
        }?.key
        return sleepType
    }
}
