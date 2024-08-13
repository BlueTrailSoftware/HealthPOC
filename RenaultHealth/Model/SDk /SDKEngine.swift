//
//  SDKEngine.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 13/08/24.
//

import Foundation

class SDKEngine {
    
    private var currentTrip: Trip = Trip()
    private var sleepDataSource = HKSleepDataSource()
    var onRestMustStart: (() -> Void)?
    
    // MARK: - Permissions
    
    static func requestHKPermission() {
        HKAuthorizationManager().requestPermissions()
    }
    
    init() {
        sleepDataSource.refreshSleepSessions(
            for: Date()
        ) {
           
            guard let lastSleepSession = self.sleepDataSource.lastSleepSession else {
                return
            }
            
            self.currentTrip.start(
                lastSleepSession: lastSleepSession,
                timerWasFired: nil
            ) {
                // Rest must start
                self.onRestMustStart?()
            }
        }
    }
}
