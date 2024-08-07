//
//  Trip.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 07/08/24.
//

import Foundation

enum TripStatus {
    case running, completed, idle
}

class Trip {
    
    private var startDate: Date = Date()
    private var lastSleepSession: HKSleepSession?
    private var intervalUntilRest: TimeInterval = 0
    
    private var status: TripStatus = .idle
    
    var activityStatus: TripStatus {
        status
    }
    
    var restDate: Date? {
        startDate.addingTimeInterval(intervalUntilRest)
    }
    
    var restDatePrettyPrint: String {
        restDate?.string(withFormat: .readable) ?? ""
    }
    
    // MARK: -
    
    func start(
        lastSleepSession: HKSleepSession
    ) {
        self.startDate = Date()
        self.lastSleepSession = lastSleepSession
        calculateRestInterval()
        self.status = .running
    }
    
    func reset() {
        self.lastSleepSession = nil
        self.status = .idle
    }
    
    // MARK: - Pretty print
    
    
 
    // MARK: - Calculations
    
    private func calculateRestInterval() {
        
        guard
            let lastSleep = self.lastSleepSession
        else {
            return
        }
        
        self.intervalUntilRest = lastSleep.totalSleepDuration * 1.5
    }
    
    // MARK: - Callbacks
    
    
}
