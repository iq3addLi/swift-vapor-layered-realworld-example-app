//
//  DateFormatter+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/25.
//

import Foundation

extension DateFormatter {
    static var iso8601withFractionalSeconds: DateFormatter {
//        let formatter = ISO8601DateFormatter() // ISO8601DateFormatter is not DateFormatter:(
//        formatter.formatOptions.insert(.withFractionalSeconds)
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
}
