//
//  ValidateIssue.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/18.
//

import Foundation

/// Issue found during validation.
///
/// Realworld production is a full inspection. It was made to make the same behavior.
struct ValidateIssue {

    // MARK: Properties
    
    /// The name of the property where the issue was detected.
    let key: String

    /// Report of issue.
    let report: String
}

// MARK: Export to ValidationError

extension Array where Element == ValidateIssue {
    
    /// Export to `ValidationError`.
    /// - returns:
    ///    A `ValidateError` that aggregates an array of` ValidateIssue`.
    func generateError() -> ValidationError {
        ValidationError( errors: reduce(into: [String: [String]]()) { result, issue in
            result[issue.key] = ( result[issue.key] ?? [] ) + [ issue.report ]
        })
    }
}
