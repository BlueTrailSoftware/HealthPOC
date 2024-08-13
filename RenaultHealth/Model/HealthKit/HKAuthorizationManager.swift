//
//  HKAuthorizationManager.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import Foundation
import HealthKit
import Combine

class HKAuthorizationManager: NSObject {

    // Publisher
    var requestAuthorizationDone = PassthroughSubject<Void, Never>()

    // Properties
    
    /// An instance of HKHealthStore is used to interact with the HealthKit repository
    private let healthStore: HKHealthStore = HKHealthStore()
    
    // MARK: - Sample Types
    
    /// HK sample types required for sleep
    private func sleepSampleTypes() -> [HKSampleType] {
        // AvailableHKIdentifiers will provide the identifiers for sleep
        AvailableHKIdentifiers.sleepIdentifiers.compactMap{
            // Parse the identifiers into HK CategoryType objects
            HKObjectType.categoryType(forIdentifier: $0)
        }
    }
    
    /// HK sample types required for nutrition
    private func heartSampleTypes() -> [HKSampleType] {
        // AvailableHKIdentifiers will provide the identifiers for nutrition
        AvailableHKIdentifiers.heartIdentifiers.compactMap{
            // Parse the identifiers into HKQuantityType objects
            HKQuantityType.quantityType(forIdentifier: $0)
        }
    }
    
    // MARK: - HK Authorization
    
    /// Displays the native iOS authorization view for the user to choose the access to HK Data
    func requestPermissions() {
        
        // Create an empty array of HKSampleTypes to be requested
        var requestedTypes: [HKSampleType] = []
        requestedTypes.append(contentsOf: sleepSampleTypes())
        requestedTypes.append(contentsOf: heartSampleTypes())
        
        // Display the authorization view with the selected HKSampleTypes
        if !requestedTypes.isEmpty {
            requestHKAuthorization(types: requestedTypes)
        }
    }
    
    /// Handles displaying the native iOS permissions view for a given set of HKSampleTypes
    private func requestHKAuthorization(
        types: [HKSampleType]
    ) {
        
        // Parse into a set to avoid HKSampleTypes duplication
        let requestedTypes = Set<HKSampleType>(Array(types))
        
        // Request authorization using healthStore
        healthStore.requestAuthorization(
            toShare: nil,
            read: requestedTypes
        ) { (success, error) in
            
            // Do not handle any success or error states
            
            if !success || error != nil {
                // Error message
                print("HKAuthorizationManager: requestHKAuthorization error : \(String(describing: error))")
                return
            }
            // Success message
            print("HKAuthorizationManager: requestHKAuthorization success")
            self.requestAuthorizationDone.send(())
        }
    }
}
