//
//  HKSleepDataSource.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation
import HealthKit

class HKSleepDataSource {
    
    // Data
    private var sleepSessions: [HKSleepSession] = []
    
    // Query Manager
    private var queryManager: HKQueryManager = HKQueryManager()
    
    // MARK: - Queries
    
    func fetchSleepSegments(
        for dates: [Date],
        completion: (([HKSleepSegment]?) -> Void)?
    ) {
        
        // Get dates for given dates range
        let sortedDates = dates.sorted { date1, date2 in
            date1 < date2
        }
        
        guard
            let firstDate = sortedDates.first,
            let lastDate = sortedDates.last
        else {
            completion?([])
            return
        }
        
        fetchHKSleepSegments(
            from: firstDate,
            to: lastDate,
            completion: completion
        )
    }
    
    func fetchHKSleepSegments(
        from startDate: Date,
        to endDate: Date,
        completion: (([HKSleepSegment]?) -> Void)?
    ) {
        // Category type
        guard let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        ) else {
            completion?(nil)
            return
        }
        
        // performQuery
        queryManager.performQuery(
            sampleType: sleepType,
            from: startDate,
            to: endDate
        ) { (query, result, error) in
            
            // Error
            if let _ = error {
                // handle error
                completion?(nil)
                return
            }
            
            // Result
            guard let result = result else {
                completion?(nil)
                return
            }
            
            // Create array of HKSleepSegment
            let samples = result.compactMap{
                $0 as? HKCategorySample
            }
            
            let sleepSegments: [HKSleepSegment] = samples.compactMap{
                HKSleepSegment(
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    sleepAnalysis: HKCategoryValueSleepAnalysis(
                        rawValue: $0.value)
                )
            }
            
            completion?(sleepSegments)
        }
    }
    
    func fetchLongestSleepSession(
        for targetDay: Date,
        completion: ((HKSleepSession?) -> Void)?
    ) {
     
        let firstDate: Date = targetDay.startOfDay.modifyDateBy(
            days: -1
        )
        
        // get last date
        let lastDate: Date = targetDay.endOfDay.modifyDateBy(
            days: 1
        )
        
        fetchSleepSessions(
            from: firstDate,
            to: lastDate
        ) { [weak self] sessions in
            
            let daySessions = sessions.filter{
                
                guard let endDate = $0.endDate else {
                    return false
                }
                return (
                    targetDay.startOfDay ... targetDay.endOfDay
                ).contains(
                    endDate
                )
            }
            
            self?.sleepSessions = daySessions
            
            // Get longest sleep session
            let longestSleep = self?.longestSleepSession()
            
            completion?(longestSleep)
        }
    }
    
    private func fetchSleepSessions(
        from startDate: Date,
        to endDate: Date,
        completion: (([HKSleepSession]) -> Void)?
    ) {
        fetchHKSleepSegments(
            from: startDate,
            to: endDate
        ) { sleepSegments in
            
            self.sleepSessions = []
            
            if
                let sleepSegments = sleepSegments,
                !sleepSegments.isEmpty {
                
                // Local HealthKit data success
                self.sleepSessions = self.arrangeSleepSessions(
                    from: sleepSegments
                )
                completion?(self.sleepSessions)
            } else {
                completion?([])
            }
        }
    }
    
    func fetchSleepSessions(
        for dates: [Date],
        includeRemote: Bool,
        completion: (([HKSleepSession]) -> Void)?
    ) {
        
        // Get dates for given dates range
        let sortedDates = dates.sorted { date1, date2 in
            date1 < date2
        }
        
        guard
            let firstDate = sortedDates.first,
            let lastDate = sortedDates.last
        else {
            completion?([])
            return
        }
        
        fetchSleepSessions(
            from: firstDate,
            to: lastDate
        ) { sleepSessions in
         
            // get only the sleep sessions for the given dates
            let dateIds: [String] = dates.compactMap {
                $0.string(withFormat: .yearMonthDayNumeric)
            }
            
            let sessionsForDates = sleepSessions.filter{
                dateIds.contains($0.startingDate?.string(withFormat: .yearMonthDayNumeric) ?? "")
            }
            
            completion?(sessionsForDates)
        }
    }
    
    // MARK: - Sleep Sessions
    
    private func arrangeSleepSessions(
        from segments: [HKSleepSegment]?
    ) -> [HKSleepSession] {
        
        guard let segments = segments else {
            return []
        }
        
        // Sort segments by startDate
        let sortedSegments = segments.sorted { firstSeg, secondSeg in
            firstSeg.startDate < secondSeg.startDate
        }
        
        // Create sessions from segments
        var sessions: [HKSleepSession] = []
        var currentSession: HKSleepSession = HKSleepSession()
        
        for segment in sortedSegments {
            
            currentSession.refreshProperties()

            // if segment belongs to current session
            // - Add it to current session
            // else
            // - Create new session
            
            var segmentsAreWithinOneHour: Bool = true
            if let lastEndingDate = currentSession.endDate {
                segmentsAreWithinOneHour = segment.startDate.timeIntervalSince(lastEndingDate) <= 360
            }
            
            // add segment to curr session if it starts within the session's last ending date
            // add segment to curr session if the period from the previous session is less than an hour
            
            if !segmentsAreWithinOneHour {
                if !currentSession.segments.isEmpty {
                    sessions.append(currentSession)
                }
                currentSession = HKSleepSession()
            }
            
            currentSession.segments.append(segment)
        }
        
        if !currentSession.segments.isEmpty {
            currentSession.refreshProperties()
            sessions.append(currentSession)
        }
        
        return sessions
    }
    
    // MARK: - Filters
    
    func longestSleepSession() -> HKSleepSession? {
       
        let longestSleep = sleepSessions.sorted(
            by: { $0.totalSleepDuration > $1.totalSleepDuration }
        ).first
        
        return longestSleep
    }
}
