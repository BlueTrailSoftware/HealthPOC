//
//  HKQueryManager.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation
import HealthKit

class HKQueryManager: NSObject {

    // Properties
    
    /// An instance of HKHealthStore is used to interact with the HealthKit repository
    private let healthStore: HKHealthStore = HKHealthStore()
    
    /// This method will perform a query into the HK data
    func performQuery(
        sampleType: HKSampleType,
        from startDate: Date,
        to endDate: Date,
        completion: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) {
        
        // Build the HKQuery predicate specifying the requirements
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        // Define the sorting type for the results
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
        // Create our query with a completion block to execute
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: 0,
            sortDescriptors: [sortDescriptor]
        ) { (query, result, error) in
            completion(query, result, error)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
}


