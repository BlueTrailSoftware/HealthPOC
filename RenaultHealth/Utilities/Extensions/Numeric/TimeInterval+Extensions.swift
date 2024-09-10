//
//  TimeInterval+Extensions.swift
//  RenaultHealth
//
//  Created by Blue Trail Software on 17/07/24.
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
                "Hr",
                "Hrs"
            ),
            (
                timeValues.minutes,
                "Min",
                "Mins"
            ),
        ]

        if includeSeconds {
            values.append(
                (
                    timeValues.seconds,
                    "Sec",
                    "Secs"
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

    func formattedTime() -> String {
        let time = Int(self)

        let secondsInMinute = 60
        let secondsInHour = 3600
        let secondsInDay = 86400

        let days = time / secondsInDay
        let hours = (time % secondsInDay) / secondsInHour
        let minutes = (time % secondsInHour) / secondsInMinute
        let seconds = time % secondsInMinute

        var components: [String] = []

        if days > 0 {
            components.append(days == 1 ? "\(days) day" : "\(days) days")
        }
        if hours > 0 {
            components.append(hours == 1 ? "\(hours) hr" : "\(hours) hrs")
        }
        if minutes > 0 {
            components.append(minutes == 1 ? "\(minutes) min" : "\(minutes) mins")
        }
        if seconds > 0 {
            components.append(seconds == 1 ? "\(seconds) sec" : "\(seconds) secs")
        }

        return components.joined(separator: " ")
    }
}
