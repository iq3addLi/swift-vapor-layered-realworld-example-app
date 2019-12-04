//
//  ValidationError.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/04.
//

/// Error expressing Validation result according to Realworld specification.
///
/// ### example
///```
///{
///    "errors": {
///        "email": [
///            "has already been taken"
///        ],
///        "password": [
///            "is too short (minimum is 8 characters)"
///        ],
///        "username": [
///            "can't be blank",
///            "is too short (minimum is 1 character)",
///            "is too long (maximum is 20 characters)"
///        ]
///    }
///}
///```
public struct ValidationError: Swift.Error, Codable {
    
    /// `ValidateIssue` aggregation.
    public var errors: [String: [String]]
}
