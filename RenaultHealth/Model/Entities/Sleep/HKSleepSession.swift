//
//  HKSleepSession.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation
import HealthKit


struct SleepSessionDisplayValues: Hashable {
    var sessionValues: [SleepSessionSummaryValue] = []
    var stagesValues: [SleepStageDisplayValues] = []
    var sleepDuration: String = "0"
    var wakeUpTime: String = "none"
}

/// Values that should be displayed in the sleep table
/// This is to avoid calculatiions during the table cells setUp
struct SleepSessionSummaryValue: Hashable {
    var titleString: String?
    var valueString: String?
    var highlightValue: Bool = false
    var highlightAll: Bool = false
}

/// Represents a period on which a sleep occurred
/// It contains all the sleep stages and their duration
class HKSleepSession: NSObject {
    
    // Properties
    
    /// HKSleepSegment forming this sleep session
    var segments: [HKSleepStage] = []
    var startingDate: Date?
    var endDate: Date?
    var totalSleepDuration: TimeInterval = 0
    var summaryValues: [SleepSessionSummaryValue] = []
    
    var displayValues: SleepSessionDisplayValues = SleepSessionDisplayValues()
    
    /// Stages which are considered to be part of an active sleep
    private var activeSleepStages: [HKCategoryValueSleepAnalysis] {
        if #available(iOS 16.0, *) {
            return [
                .asleepREM,
                .asleepDeep,
                .asleepCore,
                .asleepUnspecified
            ]
        } else {
            return [.asleep]
        }
    }
    
    // MARK: - Properties
    
    /// Called to set up the properties once and avoid calculating them in real time
    func refreshProperties() {
        startingDate = calculateStartingDate()
        endDate = calculateEndDate()
        totalSleepDuration = calculateTotalSleepDuration()
        summaryValues = setUpSummaryValues()
        displayValues = setUpDisplayValues()
    }
    
    // MARK: - Getters
    
    // Getting the first starting date for all the segments
    private func calculateStartingDate() -> Date {
        
        // continue only if at least one segment exists
        guard !segments.isEmpty else {
            return Date()
        }
        
        // Sort segments' starting dates from lesser to greater
        let startingDates: [Date] = segments.compactMap{
            $0.startDate
        }.sorted(by: { $0 < $1 })
        
        // return the first of the sorted dates
        return startingDates.first ?? Date()
    }
    
    // Getting the last ending date for all the segments
    private func calculateEndDate() -> Date {
        
        // continue only if at least one segment exists
        guard !segments.isEmpty else {
            return Date()
        }
        
        // Sort segments' starting dates from greater to lesser
        let endingDates: [Date] = segments.compactMap{
            $0.endDate
        }.sorted(by: { $0 > $1 })
        
        // return the first of the sorted dates
        return endingDates.first ?? Date()
    }
    
    // MARK: - Sleep duration
    
    /// Calculates the total active sleep duration of the session
    /// The sleep duration is determined by the duration of the stages in the activeSleepStages array
    /// NOTE: The total sleep duration is not the SUM of the active sleep segments as some of them might overlap
    private func calculateTotalSleepDuration() -> Double {
        
        // Get the ative sleep segments
        let activeSleepSegments: [HKSleepStage] = segments.filter {
            if let sleepAnalysis = $0.sleepAnalysis {
                return activeSleepStages.contains(sleepAnalysis)
            }
            return false
        }
        
        // Get the intervals for the atcive sleep segments
        let dateIntervals = activeSleepSegments.compactMap {
            DateInterval(
                start: $0.startDate,
                end: $0.endDate
            )
        }
        
        // Calculate the total duration of the active sleep segments intervals
        // This takes into consideration any date intervals which might overlap
        let finalDuration = DateIntervalCalculations.calculateTotalDuration(
            for: dateIntervals
        )
        return finalDuration
    }
    
    /// Total duration of a sleep stage (HKCategoryValueSleepAnalysis)
    private func totalDuration(
        for sleepAnalysis: HKCategoryValueSleepAnalysis
    ) -> TimeInterval {
        
        // Get all segments for the given stage (sleepAnalysis)
        let segments:[HKSleepStage] = segments.filter {
            $0.sleepAnalysis == sleepAnalysis
        }
        
        // Create date intervals for each record
        let dateIntervals = segments.compactMap {
            DateInterval(
                start: $0.startDate,
                end: $0.endDate
            )
        }
        
        // Calculate the total duration of the given intervals
        // This takes into consideration any date intervals which might overlap
        let totalDuration = DateIntervalCalculations.calculateTotalDuration(
            for: dateIntervals
        )
        
        return totalDuration
    }
    
    // MARK: - Strings
    
    /// Creates the table values that should be displayed to the user
    private func setUpSummaryValues() -> [SleepSessionSummaryValue] {
        
        // sleep segments to extract
        var sleepSegmentTypes: [HKCategoryValueSleepAnalysis] = [
            .inBed,
            .awake,
        ]
        
        // sleep segments to extract
        sleepSegmentTypes.append(contentsOf: activeSleepStages)
        
        // Calulate the data and create an array of SleepSessionTableValue objects
        var tableValues = sleepSegmentTypes.compactMap {
            SleepSessionSummaryValue(
                titleString: HKSleepProperties.displayName(sleepSegmentType: $0),
                valueString: totalDuration(for: $0).verboseTimeString(),
                highlightValue: activeSleepStages.contains($0)
            )
        }
        
        // Get the sleep duration string
        var durationString: String = totalSleepDuration.verboseTimeString()
        if durationString.isEmpty {
            durationString = "noData"
        }
        
        // Append the total duration string value
        tableValues.append(
            SleepSessionSummaryValue(
                titleString: "Total sleep duration",
                valueString: durationString,
                highlightAll: true
            )
        )
        
        return tableValues
    }
    
    private func setUpDisplayValues() -> SleepSessionDisplayValues {
        return SleepSessionDisplayValues(
            sessionValues: summaryValues,
            stagesValues: segments.map{ $0.tableValues },
            sleepDuration: totalSleepDuration.verboseTimeString(),
            wakeUpTime: endDate?.string(withFormat: .readable) ?? "none"
        )
    }
}
