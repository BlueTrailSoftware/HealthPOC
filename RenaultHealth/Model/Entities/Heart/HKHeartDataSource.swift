//
//  HKHeartDataSource.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 29/07/24.
//

import Foundation
import HealthKit

struct HRVEntry {
    var value: Double
    var startDate: Date
    var endDate: Date
}

class HKHeartDataSource: NSObject {
    
    // Managers
    private var queryManager: HKQueryManager = HKQueryManager()
    
    func fetchHRV(
        from startDate: Date,
        to endDate: Date,
        completion: (([HRVEntry]?) -> Void)?
    ) {
        
        // Quantity type
        guard let quantityType = HKQuantityType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        ) else {
            completion?(nil)
            return
        }
        
        // Perform query
        queryManager.performQuery(
            sampleType: quantityType,
            from: startDate,
            to: endDate
        ) { query, samples, error in
            
            guard let samples = samples else {
                completion?(nil)
                return
            }
            
            let entries = samples.compactMap { sample in
                
                let quantityValue: Double = (sample as? HKQuantitySample)?.quantity.doubleValue(
                    for: .secondUnit(with: .milli)
                ) ?? 0.0
                
                return HRVEntry(
                    value: quantityValue,
                    startDate: sample.startDate,
                    endDate: sample.endDate
                )
            }

            print("HRV_entries : ", entries)
            
            completion?(entries)
        }
    }
}
