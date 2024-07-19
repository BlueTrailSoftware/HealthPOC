//
//  DateIntervalCalculations.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation

class DateIntervalCalculations: NSObject {

    static func calculateTotalDuration(
        for dateIntervals: [DateInterval]
    ) -> Double {
        
        var newIntervals: Set<DateInterval> = []
        dateIntervals.forEach { currInterval in
            var didIntersect: Bool = false
            newIntervals.forEach { otherInterval in
                
                if currInterval.intersects(otherInterval) {
                    didIntersect = true
                    let lesserDate = currInterval.start.compare(
                        otherInterval.start
                    ) == .orderedAscending ?
                    currInterval.start : otherInterval.start
                    
                    let greaterDate = currInterval.end.compare(
                        otherInterval.end
                    ) == .orderedDescending ?
                    currInterval.end : otherInterval.end
                    
                    let newInterval = DateInterval(
                        start: lesserDate,
                        end: greaterDate
                    )
                    
                    newIntervals.remove(otherInterval)
                    newIntervals.insert(newInterval)
                }
            }
            
            if !didIntersect {
                newIntervals.insert(currInterval)
            }
        }
        
        let finalDuration = newIntervals.compactMap{
            $0.duration
        }.reduce(0, +)
        return finalDuration
    }
}
