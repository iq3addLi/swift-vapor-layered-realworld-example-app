//
//  Error.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/21.
//

/// Domain layer's error.
///
/// TODO: It's not good to leave it as it's if I want to improve it.😓
struct Error: Swift.Error {
    
    // MARK: Properties
    
    /// Reason of error.
    let reason: String
    
    /// Applicable HTTPErrorCode.
    let status: Int

    // MARK: Initalizer
    
    /// Default initializer.
    /// - Parameters:
    ///   - reason: Reason of error.
    ///   - status: Applicable HTTPErrorCode.
    init(_ reason: String, status: Int = 404) {
        self.reason = reason
        self.status = status
    }
}

