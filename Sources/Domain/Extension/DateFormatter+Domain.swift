//
//  DateFormatter+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/25.
//

import Foundation

// MARK: Customizing DateFormatter

/// Extensions required by Domain.
extension DateFormatter {

    /// DataFormatter that handles milliseconds.
    ///
    /// DateEncodingStrategy.iso8601 does not handle milliseconds, so this Formatter is prepared.
    public static var iso8601withFractionalSeconds: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
}
