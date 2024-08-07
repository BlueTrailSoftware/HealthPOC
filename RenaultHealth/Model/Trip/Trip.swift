//
//  Trip.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 07/08/24.
//

import Foundation

class Trip {
    
    private var startDate: Date?
    private var lastSleepSession: HKSleepSession?
    private var intervalUntilRest: TimeInterval = 0
    
    var restDate: Date? {
        startDate?.addingTimeInterval(intervalUntilRest)
    }
    
    func start(date: Date, lastSleep: HKSleepSession) {
        self.startDate = date
        self.lastSleepSession = lastSleep
        
        calculateRestInterval()
    }
 
    private func calculateRestInterval() {
        
        guard
            let startDate = self.startDate,
            let lastSleep = self.lastSleepSession
        else {
            return
        }
        
        self.intervalUntilRest = lastSleep.totalSleepDuration * 1.5
    }
}
