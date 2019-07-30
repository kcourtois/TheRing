//
//  DateFormatting.swift
//  TheRing
//
//  Created by Kévin Courtois on 29/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class DateFormatting {
    //Takes a date and return a localized string
    static func dateToLocalizedString(date: Date) -> String {
        let formatDate = DateFormatter()
        formatDate.dateStyle = .short
        formatDate.timeStyle = .short
        formatDate.locale = Locale(identifier: NSLocale.current.identifier)
        return formatDate.string(from: date)
    }

    //Takes a date and returns a string formated in a specific order
    static func dateToString(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return dateFormatter.string(from: date)
    }

    //Takes a string formated in a specific order and returns a date
    static func stringToDate(str: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return dateFormatter.date(from: str)
    }

    static func yearMonthDayStrToDate(str: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: str)
    }
}
