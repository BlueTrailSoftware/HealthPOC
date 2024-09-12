//
//  HKSleepSegment.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation
import HealthKit

struct SleepStageDisplayValues: Hashable {
    var title: String = ""
    var start: String = ""
    var end: String = ""
    var duration: String = ""
    var highlight: Bool = false
}

/// Represents a sleep stage (HKCategoryValueSleepAnalysis) with their start and end dates
struct HKSleepStage: JSONDecodable {
    var startDate: Date = Date()
    var endDate: Date = Date()
    var sleepAnalysis: HKCategoryValueSleepAnalysis?
    
    var tableValues: SleepStageDisplayValues {
        SleepStageDisplayValues(
            title: HKSleepProperties.displayName(
                sleepSegmentType: sleepAnalysis ?? .asleepUnspecified
            ) ?? "unknown" ,
            start: startDate.string(withFormat: StringDateFormat.readable),
            end: endDate.string(withFormat: StringDateFormat.readable),
            duration: DateIntervalCalculations.calculateTotalDuration(
                for: [
                    DateInterval(
                        start: startDate,
                        end: endDate
                    )
                ]
            ).verboseTimeString(),
            highlight: sleepAnalysis == .asleepCore || sleepAnalysis == .asleepREM || sleepAnalysis == .asleepDeep || sleepAnalysis == .asleepUnspecified
        )
    }

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
    
    
}
