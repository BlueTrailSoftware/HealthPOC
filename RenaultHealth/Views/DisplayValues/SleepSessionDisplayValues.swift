//
//  SleepSessionDisplayValues.swift
//  RenaultHealth
//
//

import Foundation

struct SleepSessionDisplayValues: Hashable {
    var sessionValues: [SleepSessionSummaryValue] = []
    var stagesValues: [SleepStageDisplayValues] = []
    var sleepDuration: String = "0"
    var wakeUpTime: String = "none"
}
