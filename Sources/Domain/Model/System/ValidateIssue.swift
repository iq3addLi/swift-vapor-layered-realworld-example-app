//
//  ValidateIssue.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/18.
//

import Foundation

/// <#Description#>
struct ValidateIssue {

    /// <#Description#>
    let key: String

    /// <#Description#>
    let report: String
}

extension Array where Element == ValidateIssue {

    /// <#Description#>
    func generateError() -> ValidationError {
        var errors: [String: [String]] = [:]
        self.forEach { issue in
            errors[issue.key] = self.filter { issue.key == $0.key }.map { $0.report }
        }
        return ValidationError( errors: errors )
    }
}

/// <#Description#>
public struct ValidationError: Swift.Error, Codable {
    public var errors: [String: [String]]
}
