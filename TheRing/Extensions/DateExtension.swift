//
//  DateFormatting.swift
//  TheRing
//
//  Created by Kévin Courtois on 29/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

extension Date {
    //Takes a date and return a localized string
    func dateToLocalizedString(locale: Locale = Locale(identifier: NSLocale.current.identifier)) -> String {
        let formatDate = DateFormatter()
        formatDate.dateStyle = .short
        formatDate.timeStyle = .short
        formatDate.locale = locale
        return formatDate.string(from: self)
    }

    //Takes a date and returns a string formated in a specific order
    func dateToString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return dateFormatter.string(from: self)
    }

    //Takes a string formated in a specific order and returns a date
    init?(dateStringWithHM: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        if let date = dateFormatter.date(from: dateStringWithHM) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }

    //Takes a string formated in a specific order and returns a date
    init?(dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }
}
