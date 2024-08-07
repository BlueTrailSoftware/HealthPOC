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
    
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    var timerWasFired: (() -> Void)?
    
    var activityStatus: TripStatus {
        status
    }
    
    var restDate: Date? {
        startDate.addingTimeInterval(intervalUntilRest)
    }
    
    // MARK: - Pretty print
    
    var startDatePretty: String {
        startDate.string(withFormat: .readable)
    }
    
    var restDatePretty: String {
        restDate?.string(withFormat: .readable) ?? ""
    }
    
    var elapsedTimePretty: String {
        elapsedTime.verboseTimeString(
            includeSeconds: true
        )
    }
    
    var intervalUntilRestPretty: String {
        (intervalUntilRest - elapsedTime).verboseTimeString(
            includeSeconds: true
        )
    }
    
    // MARK: - Setters
    
    func start(
        lastSleepSession: HKSleepSession,
        timerWasFired: (() -> Void)? = nil
    ) {
        self.startDate = Date()
        self.lastSleepSession = lastSleepSession
        self.elapsedTime = 0
        
        self.timerWasFired = timerWasFired
        calculateRestInterval()
        startTimer()
        
        self.status = .running
    }
    
    func reset() {
        self.lastSleepSession = nil
        self.stopTimer()
        self.status = .idle
        self.elapsedTime = 0
    }
 
    // MARK: - Calculations
    
    private func calculateRestInterval() {
        
        guard
            let lastSleep = self.lastSleepSession
        else {
            return
        }
        
        self.intervalUntilRest = lastSleep.totalSleepDuration * 1.5
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(timerTasks),
            userInfo: nil, repeats: true
        )
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc private func timerTasks(timer: Timer) {
        self.elapsedTime += 1
        print("elapsedTime : \(elapsedTime) ::: \(intervalUntilRest) ::: \(elapsedTimePretty) ::: \(intervalUntilRestPretty)")
        
        timerWasFired?()
        
        if elapsedTime == intervalUntilRest {
            status = .completed
            stopTimer()
        }
    }
}
