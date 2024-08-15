//
//  SleepSessionSummaryValue.swift
//  RenaultHealth
//
//

import Foundation

/// Values that should be displayed in the sleep table
/// This is to avoid calculatiions during the table cells setUp
struct SleepSessionSummaryValue: Hashable {
    var titleString: String?
    var valueString: String?
    var highlightValue: Bool = false
    var highlightAll: Bool = false
}
