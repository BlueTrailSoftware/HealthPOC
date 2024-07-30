//
//  TimeInterval+Extensions.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation

extension TimeInterval{
    
    func verboseTimeString(
        includeSeconds: Bool = false
    ) -> (String) {
        
        let timeValues = toHours()
        var values: [(value: Int, singular: String, plural: String)] = [
            (
                timeValues.hour,
                "Hour",
                "Hours"
            ),
            (
                timeValues.minutes,
                "Min",
                "Min"
            ),
        ]
        
        if includeSeconds {
            values.append(
                (
                    timeValues.seconds,
                    "Sec",
                    "Sec"
                )
            )
        }
        
        var answer: String = ""
        values.forEach {
            
            if !answer.isEmpty {
                answer += " "
            }
            
            if $0.value > 0 {
                let fieldName: String = $0.value == 1 ? $0.singular : $0.plural
                answer += "\($0.value) \(fieldName)"
            }
        }
        
        return answer
    }
    
    func toHours() -> (
        hour: Int,
        minutes: Int,
        seconds: Int,
        ms: Int
    ) {
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return (hours, minutes, seconds, ms)
    }
}

