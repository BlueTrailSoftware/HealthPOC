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
    
    // MARK: - Filters
    
    var allSleepSessions: [HKSleepSession] {
        sleepSessions
    }
    
    var longestSleepSession: HKSleepSession? {
        sleepSessions.sorted(
            by: { $0.totalSleepDuration > $1.totalSleepDuration }
        ).first
    }
    
    var lastSleepSession: HKSleepSession? {
        let endDates = sleepSessions.map { $0.endDate }

        print("HKSDS_lastSleepSession_sessions : \(endDates)")
       
        let sorted = sleepSessions.sorted(
            by: { $0.endDate ?? Date() > $1.endDate ?? Date() }
        )
        
        print("HKSDS_lastSleepSession_sorted : \(sorted)")
        
        let sorted_endDates = sorted.map { $0.endDate }
        print("HKSDS_lastSleepSession_sessions_sorted_endDates : \(sorted_endDates)")
        
        let lastSleep = sorted.first
        
        print("HKSDS_lastSleepSession_lastSleep : \(String(describing: lastSleep?.totalSleepDuration))")
        
        return lastSleep
    }
    
    // MARK: - Queries
    
    // MARK: Sleep stages
    
    func fetchSleepStages (
        for dates: [Date],
        completion: (([HKSleepStage]?) -> Void)?
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
        
        fetchHKSleepStages(
            from: firstDate,
            to: lastDate,
            completion: completion
        )
    }
    
    func fetchHKSleepStages(
        from startDate: Date,
        to endDate: Date,
        completion: (([HKSleepStage]?) -> Void)?
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
            
            let sleepSegments: [HKSleepStage] = samples.compactMap{
                HKSleepStage(
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    sleepAnalysis: HKCategoryValueSleepAnalysis(
                        rawValue: $0.value)
                )
            }
            
            completion?(sleepSegments)
        }
    }
    
    // MARK: Sleep sessions
    
    private func fetchSleepSessions(
        from startDate: Date,
        to endDate: Date,
        completion: (() -> Void)?
    ) {
        fetchHKSleepStages(
            from: startDate,
            to: endDate
        ) { sleepSegments in
            
            guard 
                let sleepSegments = sleepSegments,
                !sleepSegments.isEmpty
            else {
                completion?()
                return
            }
            
            self.sleepSessions = self.arrangeSleepSessions(from: sleepSegments)
            completion?()
        }
    }
    
    func refreshSleepSessions(
        for targetDay: Date,
        completion: (() -> Void)?
    ) {
        
        
        let firstDate: Date = targetDay.startOfDay.modifyDateBy(days: -1)
        /*
           // get last date
        let lastDate: Date = targetDay.endOfDay.modifyDateBy(days: 1)
        */
            
        fetchSleepSessions(
            from: firstDate,
            to: targetDay,
            completion: completion
        )
    }
    
    // MARK: - Sleep Sessions
    
    private func arrangeSleepSessions(
        from segments: [HKSleepStage]?
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
}
