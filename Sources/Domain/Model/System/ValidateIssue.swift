//
//  ValidateIssue.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/18.
//

import Foundation

/// Issue found during validation
///
/// Realworld production is a full inspection. It was made to make the same behavior.
struct ValidateIssue {

    // MARK: Properties
    
    /// <#Description#>
    let key: String

    /// <#Description#>
    let report: String
}

extension Array where Element == ValidateIssue {

    // MARK: Functions
    
    /// <#Description#>
    func generateError() -> ValidationError {
        var errors: [String: [String]] = [:]
        self.forEach { issue in
            errors[issue.key] = self.filter { issue.key == $0.key }.map { $0.report }
        }
        return ValidationError( errors: errors )
    }
}

/// Error expressing Validation result according to Realworld specification.
public struct ValidationError: Swift.Error, Codable {
    public var errors: [String: [String]]
}
