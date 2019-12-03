//
//  Error.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/21.
//

/// Domain layer's error
struct Error: Swift.Error {
    let reason: String
    let status: Int

    ///
    /// - Parameter reason: <#reason description#>
    init(_ reason: String, status: Int = 404) {
        self.reason = reason
        self.status = status
    }
}

