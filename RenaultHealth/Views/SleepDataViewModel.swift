//
//  SleepDataViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 18/07/24.
//

import Foundation
import SleepSDK
import Combine

class SleepDataViewModel: ObservableObject {
    
    @Published var sleepValues: [SleepSessionTableValue] = []
    @Published var sleepSegments: [SleepSegmentTableValue] = []
    @Published var isRefreshing: Bool = false
    
    //private var dataSource = HKSleepDataSource()
    private let healthDataProvider = HealthDataProvider()
    private var cancellables = Set<AnyCancellable>()
    
    func setUp() {
        requestHKPermission()
        setupSleepBindings()
        fetchSleepData()
    }
    
    func requestHKPermission() {
        healthDataProvider.requestHealthKitPermission()
    }
    
    func fetchSleepData() {
        healthDataProvider.fecthSleepData()
    }
    
    func setupSleepBindings() {
        healthDataProvider.isLoading
                .sink { loading in
                    // Aqui lo que quieras hacer con el estado del loading
                    self.isRefreshing = loading
                }.store(in: &cancellables)

        healthDataProvider.sleepValues
                .sink { values in
                    // Aqui lo que llena tu tabla  de valores
                    self.sleepValues = values
                }.store(in: &cancellables)

        healthDataProvider.sleepSegments
                .sink { segments in
                    // Aqui lo que llena tu tabla de segmentos
                    self.sleepSegments = segments
                }.store(in: &cancellables)
    }
}
