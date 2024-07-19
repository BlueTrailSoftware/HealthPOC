//
//  HKSleepSegment.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation
import HealthKit

/// Represents a sleep stage (HKCategoryValueSleepAnalysis) with their start and end dates
struct HKSleepSegment: JSONDecodable {
    var startDate: Date = Date()
    var endDate: Date = Date()
    var sleepAnalysis: HKCategoryValueSleepAnalysis?

    // MARK: - Init
    
    init(
        startDate: Date,
        endDate: Date,
        sleepAnalysis: HKCategoryValueSleepAnalysis?
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.sleepAnalysis = sleepAnalysis
    }
    
    init(container: JSONDictionary) throws {
    
        // Get the start date
        let startDateString: String = try "start_date" <- container
        startDate = startDateString.stringToDate(
            format: .formatISO8601,
            timeZone: .current
        ) ?? Date()
        
        // Get the end date
        let endDateString: String = try "end_date" <- container
        endDate = endDateString.stringToDate(
            format: .formatISO8601,
            timeZone: .current
        ) ?? Date()
        
        // Get the sleep stage
        sleepAnalysis = .asleepUnspecified
        let sleepStage: String = try "sleep_stage" <- container
        
        // Get a HKCategoryValueSleepAnalysis from their string
        if let sleepSegmentType = HKSleepProperties.sleepSegmentType(with: sleepStage) {
            sleepAnalysis = sleepSegmentType
        }
    }
    
    // MARK: - Getters
    
    /// Dictionary to be used when uploading data to the server
    func payloadDictionary() -> [String: Any] {
        
        // Get the start date
        let startTime = startDate.string(
            withFormat: .formatISO8601
        )
        
        // Get the end date
        let endTime = endDate.string(
            withFormat: .formatISO8601
        )
        
        // Create the data dictionary
        let data = [
            "start_date": startTime,
            "end_date": endTime,
            "sleep_stage": HKSleepProperties.stringId(
                sleepSegmentType: sleepAnalysis ?? .asleepUnspecified
            )
        ]
        
        // Create the metadata dictionary
        let metadata = [
            "startTime": startTime,
            "endTime": endTime
        ]
        
        return [
            "data": data,
            "metadata": metadata
        ]
    }
}
