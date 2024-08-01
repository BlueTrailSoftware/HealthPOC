//
//  Date+Extensions.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation

extension Date {

    fileprivate static let formatter = {
        return DateFormatter()
    }()

    var startOfDay: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }

    var endOfDay: Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        guard let result = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { fatalError("Could not get start of week") }
        return result
    }

    var dayOfWeek: Int {
        let calendar = Calendar.current
        let result = calendar.component(.weekday, from: self)
        return result
    }

    var weekOfYear: Int {
        let calendar = Calendar.current
        let result = calendar.component(.weekOfYear, from: self)
        return result
    }

    var endOfWeek: Date {
        let calendar = Calendar.current
        let startOfWeek = self.startOfWeek
        guard let result = calendar.date(byAdding: .day, value: 6, to: startOfWeek, wrappingComponents: false) else { fatalError("Could not get end of week") }
        return result
    }

    func string(
        withFormat format: StringDateFormat = StringDateFormat.formatDay,
        and timeZone: TimeZone = TimeZone(abbreviation: "UTC")!,
        locale: Locale = Locale(identifier: "en_US")
    ) -> String {
        Date.formatter.dateFormat = format.rawValue
        Date.formatter.timeZone = timeZone
        Date.formatter.locale = locale
        return Date.formatter.string(from: self)
    }

    func dateAndTime(selectedDate: Date?) -> Date {
        let calendar = Calendar.current
        //get components from date
        let timeDateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        // get components from selected date
        let selectedDateComponents = selectedDate == nil ? calendar.dateComponents([.year, .month, .day], from: Date()) : calendar.dateComponents([.year, .month, .day], from: selectedDate!)

        //create components from date and selectedDate
        var newDateComponents = DateComponents()
        newDateComponents.year = selectedDateComponents.year
        newDateComponents.month = selectedDateComponents.month
        newDateComponents.day = selectedDateComponents.day
        newDateComponents.hour = timeDateComponents.hour
        newDateComponents.minute = timeDateComponents.minute
        newDateComponents.second = timeDateComponents.second

        guard let dateAndTime = calendar.date(from: newDateComponents) else { return Date() }
        return dateAndTime
    }

    func startOfMonth() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: components)
        return startOfMonth
    }

    func dateByAddingMonths(_ monthsToAdd: Int) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: self)
    }

    func endOfMonth() -> Date? {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        let calendar = Calendar.current
        guard let startOfMonth = startOfMonth() else { return nil }
        let endOfMonth = calendar.date(byAdding: components, to: startOfMonth)
        return endOfMonth
    }

    func isDateInCurrentMonth() -> Bool {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month], from: self)
        let currentDateComponents = calendar.dateComponents([.year, .month], from: Date())
        return dateComponents == currentDateComponents
    }

    func dateForAPastHotflash(hour: Int) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)

        var newDateComponents = DateComponents()
        newDateComponents.year = components.year
        newDateComponents.month = components.month
        newDateComponents.day = components.day
        newDateComponents.hour = hour
        newDateComponents.minute = 00
        newDateComponents.second = 00

        guard let dateAndTime = calendar.date(from: newDateComponents) else { return Date() }
        return dateAndTime
    }

    func daysBetweenTwoDates(endDate: Date) -> Int {
        let calendar = Calendar.current
        let startDate = self.startOfDay
        let endDate = endDate.startOfDay

        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        guard let days = components.day else { return 0 }
        return days
    }

    var hourOfDate: Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)

        return hour
    }

    var minuteOfDate: Int {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: self)

        return minute
    }

    var secondOfDate: Int {
        let calendar = Calendar.current
        let second = calendar.component(.second, from: self)

        return second
    }

    func dateMonthString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = StringDateFormat.formatMonthNameAbb.rawValue
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self).capitalized
    }

    func dateDayNumber() -> Int {
        return Calendar.current.component(.day, from: self)
    }

    func dateYearNumber() -> Int {
        return Calendar.current.component(.year, from: self)
    }

    func dateTimeString(withFormat format: StringDateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        return formatter.string(from: self)
    }

    func addDays(amount: Int) -> Date {
        return self.modifyDateBy(days: amount, hours: 0, minutes: 0, seconds: 0)
    }
    
    func modifyDateBy(
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0
    ) -> Date {
        let calendar = Calendar.current
        
        var offsetComponents = DateComponents()
        offsetComponents.day = days
        offsetComponents.hour = hours
        offsetComponents.minute = minutes
        offsetComponents.second = seconds

        guard let retValue = calendar.date(
            byAdding: offsetComponents,
            to: self
        ) else {
            return Date()
        }

        return retValue
    }

    static let dateFormatter = { () -> DateFormatter in
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter
    }()

    static let dateFormatterCurrentTZ = { () -> DateFormatter in
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter
    }()

    func toUTCDate() -> Date {
        let dateStr = Date.dateFormatterCurrentTZ.string(from: self)
        return Date.dateFormatter.date(from: dateStr)!
    }

    static func dates(
        from fromDate: Date,
        to toDate: Date
    ) -> [Date] {
            var dates: [Date] = []
            var date = fromDate

            while date <= toDate {
                dates.append(date)
                guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
                date = newDate
            }
            return dates
        }
}

enum StringDateFormat: String {
    case formatISO8601 = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    case formatISO8601Extended = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case formatBirth = "MM/dd/yyyy"
    case formatDayStart = "yyyy-MM-dd'T'00:00:00'Z'"
    case formatDayEnd = "yyyy-MM-dd'T'23:59:59'Z'"
    case formatMonthNameAbb = "MMM"
    case formatTime12Hours = "h:mm a"
    case formatDay = "yyyy-MM-dd'T'hh:mm:ss'Z'"
    case formatMonthNameDayYear = "MMM dd, yyyy"
    case formatMonthNameDayYearTime = "MMM dd, yyyy HH:mm"
    case dayNameMonthYearShourtTime = "EEE, MMM d, yyyy HH:mm"
    case yearMonthDayNumeric = "yyyyMMdd"
    case monthNameDayName = "MMM dd"
    case basic = "dd-MM-yyyy HH:mm:ss"
    case readable = "E, d MMM, HH:mm:ss"
}

extension String {
    func stringToDate(
        format: StringDateFormat,
        timeZone: TimeZone? = TimeZone(abbreviation: "UTC")
    ) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: self)
    }
}
