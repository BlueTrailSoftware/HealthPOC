//
//  HKHeartDataSource.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 29/07/24.
//

import Foundation
import HealthKit

class HKHeartDataSource: NSObject {
    
    // Managers
    private var queryManager: HKQueryManager = HKQueryManager()
    
    func fetchIdentifierData(
        identifier: HKQuantityTypeIdentifier,
        from startDate: Date,
        to endDate: Date,
        completion: (() -> Void)?
    ) {
        
        // Quantity type
        guard let quantityType = HKQuantityType.quantityType(
            forIdentifier: identifier
        ) else {
            completion?()
            return
        }
        
        /*
        // Get identifier properties
        let idProperties = HKNutrientIdsProperties.properties(for: identifier)
        let nutrientGroup: HKNutrientGroup = idProperties?.nutrientGroup ?? .macronutrients
        let displayName: String = idProperties?.displayName ?? ""
        let preferredUnit: HKUnit = idProperties?.preferredUnit ?? .gram()
        
        // Build HKNutritionIdData object
        let answer = HKNutrientIdData(
            quantityTypeId: identifier,
            nutrientGroup: nutrientGroup,
            displayName: displayName,
            preferredUnit: preferredUnit,
            periodStartDate: startDate,
            periodEndDate: endDate
        )
         */
        
        // Perform query
        queryManager.performQuery(
            sampleType: quantityType,
            from: startDate,
            to: endDate
        ) { query, samples, error in
            
            // Create a HKNutritionIdDataItem for each sample and append it to HKNutritionIdData.values
            samples?.forEach { sample in
                
                let quantityValue: Double = (sample as? HKQuantitySample)?.quantity.doubleValue(
                    for: .secondUnit(with: .milli)
                ) ?? 0.0
                
                print("HRV : ", quantityValue)
                
                /*
                let dataItem = HKNutritionIdDataEntry(
                    quantityTypeId: identifier,
                    startDate: sample.startDate,
                    endDate: sample.endDate,
                    value: quantityValue
                )
                answer.append(entry: dataItem)
                 */
            }
            
            //completion?(answer)
        }
    }
}
