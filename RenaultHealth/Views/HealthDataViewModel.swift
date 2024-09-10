//
//  SleepDataViewModel.swift
//  RenaultHealth
//
//  Created by Blue Trail Software on 18/07/24.
//

import Foundation
import SwiftUI
import Observation
import Combine
import DaciaHealthKit

enum TripState {
    case none, running, completed
}

@Observable
class HealthDataViewModel {

    private let healthProvider = HealthDataProvider()
    private var cancellables = Set<AnyCancellable>()

    // Publlishers
    var isRefreshing: Bool = true
    var tripTimeBeforeRest: Double = 0
    var elapsedTime: Double = 0
    var restNow: Bool = false
    var errorType: DaciaHealthError? = nil

    // Trip
    var canStartTrip: Bool = false
    var tripMessage: String = "New Trip"
    var tripMessageColor: Color = .black.opacity(0.4)
    var tripActionButtonText: String = "Start"
    var tripActionButtonBackground: Color = .teal

    var tripStatus: TripState = .none

    // MARK: - Permissions
    func requestHKPermission() {
        setupBindings()
        healthProvider.requestHealthPermissions()

        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0..<2)) {
            self.isRefreshing = false
        }
    }

    // MARK: - Bindings
    private func setupBindings() {
        healthProvider.tripTimeBeforeRest
            .sink { time in
                print("tiempo para descansar: ", time)
                guard !time.isZero else {
                    self.canStartTrip = false
                    return
                }

                self.canStartTrip = true
                self.tripTimeBeforeRest = time
            }
            .store(in: &cancellables)

        healthProvider.tripElapsedTime
            .sink { time in
                print("Elapsed time: ", time)
                self.elapsedTime = time
                self.tripStatus = .running
                self.refreshTripPublishedValues()
            }
            .store(in: &cancellables)

        healthProvider.restNow
            .sink {
                self.restNow = true
                self.tripStatus = .completed
                self.refreshTripPublishedValues()
            }
            .store(in: &cancellables)

        healthProvider.healthDataProviderError
            .sink { error in
                print(error.message)
                self.errorType = error
            }
            .store(in: &cancellables)

    }

    func refreshTripTime() {
        isRefreshing = true
        errorType = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0..<3)) {
            self.healthProvider.calculateTripTime()
            self.isRefreshing = false
        }
    }

    // MARK: - Trip
    func toggleTrip() {
        if tripStatus == .none {
            healthProvider.startTrip()
        } else {
            healthProvider.stopTrip()
        }

        refreshTripPublishedValues()
    }
/*
    private func refreshTripInfo() {
        self.tripValues = TripPrettyPrintValues(
            startDate: self.currentTrip.startDatePretty,
            restDate: self.currentTrip.restDatePretty,
            elapsedTime: self.currentTrip.elapsedTimePretty,
            intervalUntilRest: self.currentTrip.intervalUntilRestPretty,
            realTimeIntervalUntilRest: self.currentTrip.realTimeIntervalUntilRestPretty
        )

        refreshTripPublishedValues()
    }
 */
    private func refreshTripPublishedValues() {
        switch tripStatus {
        case .running:
            tripActionButtonText = "Stop"
            tripActionButtonBackground = .red
            tripMessage = "Running trip"
            tripMessageColor = .orange

        case .completed:
            tripActionButtonText = "Rest Now!"
            tripActionButtonBackground = .blue
            tripMessage = "Rest now!"
            tripMessageColor = .red

        case .none:
            tripActionButtonText = "Start"
            tripActionButtonBackground = .teal
            tripMessage = "New Trip"
            tripMessageColor = .black.opacity(0.4)
        }
    }

}
