//
//  Error.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/21.
//

/// dummy comment
struct Error: Swift.Error {
    let reason: String

    /// <#Description#>
    /// - Parameter reason: <#reason description#>
    init(_ reason: String) {
        self.reason = reason
    }
}
