//
//  ValidateIssue.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/18.
//

import Foundation

struct ValidateIssue{
    let key: String
    let report: String
}

extension Array where Element == ValidateIssue{
    func generateReport() -> ValidationError {
        var errors: [String: [String]] = [:]
        self.forEach{ issue in
            errors[issue.key] = self.filter{ issue.key == $0.key }.map{ $0.report }
        }
        return ValidationError( errors: errors )
    }
}


public struct ValidationError: Swift.Error, Codable {
    public var errors: [String: [String]]
}
