//
//  Validation.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/18.
//

import Validation

/// This class has the validation function required for this project.
///
/// [vapor/validation](https://github.com/vapor/validation) is adopted as Infrastructure.
/// This class was prepared because realworld's production implementation (https://conduit.productionready.io/api) validation was an exhaustive check. At first, Validatable was used.
///
/// ### Extras
/// As an aside, I like vapor/validation. This is because there is a usage that is loosely coupled to vapor/vapor.
/// If it is an add-in to vapor/vapor Package like fluent, I think it is better. Looking [here](https://github.com/vapor/vapor/blob/4.0.0-beta.1/Package.swift), I expect it will probably be in the future.
final class Validation {

    // MARK: Futureization
    
    /// Returns validation processing as Future.
    /// - Parameters:
    ///   - validator: `Validation.Validator<String>` responsible for validation.
    ///   - key: The name of the parameter to validate.
    ///   - value: The value of the parameter to validate.
    ///   - report: Report when verification fails, paired with veridator.
    /// - returns:
    ///    The `Future` that returns `ValidateIssue` or nil. Nil is means hasn't issue.
    func willDo( validator: Validator<String>, key: String, value: String, report: String ) -> Future<ValidateIssue?> {
        guard let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop else {
            fatalError("The current event loop is not found.")
        }

        return eventLoop.submit { () -> ValidateIssue? in
            do { try validator.validate(value) } catch { return ValidateIssue(key: key, report: report) }
            return nil
        }
    }
}

// MARK: Set Validation to Future

extension Validation {
    
    /// Returns lower bound validation processing as Future.
    /// - Parameters:
    ///   - range: Lower bound as `PartialRangeFrom<Int>`
    ///   - key: The name of the parameter to validate.
    ///   - value: The value of the parameter to validate.
    /// - warning:
    ///    Please execute in Thread of SwiftNIO.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func count(_ range: PartialRangeFrom<Int>, key: String, value: String ) -> Future<ValidateIssue?> {
        willDo(validator: Validator<String>.count(range), key: key, value: value, report: "is too short (minimum is \(range.lowerBound) characters)")
    }

    /// Returns upper bound validation processing as Future.
    /// - Parameters:
    ///   - range: Upper bound as `PartialRangeThrough<Int>`
    ///   - key: The name of the parameter to validate.
    ///   - value: The value of the parameter to validate.
    /// - warning:
    ///   Please execute in Thread of SwiftNIO.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func count(_ range: PartialRangeThrough<Int>, key: String, value: String ) -> Future<ValidateIssue?> {
        willDo(validator: Validator<String>.count(range), key: key, value: value, report: "is too long (maximum is \(range.upperBound) characters)")
    }

    /// Returns not blank validation processing as Future.
    /// - Parameter key: The name of the parameter to validate.
    /// - Parameter value: The value of the parameter to validate.
    /// - warning:
    ///   Please execute in Thread of SwiftNIO.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func blank( key: String, value: String ) -> Future<ValidateIssue?> {
        willDo(validator: !Validator<String>.empty, key: key, value: value, report: "can't be blank")
    }

    /// Returns email validation processing as Future.
    /// - Parameter value: The email to validate.
    /// - warning:
    ///   Please execute in Thread of SwiftNIO.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func email(_ value: String ) -> Future<ValidateIssue?> {
        willDo(validator: Validator<String>.email, key: "email", value: value, report: "is invalid" )
    }

    /// Returns url validation processing as Future.
    /// - Parameter key: The name of the parameter to validate.
    /// - Parameter value: The url to validate.
    /// - warning:
    ///   Please execute in Thread of SwiftNIO.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func url( key: String, value: String ) -> Future<ValidateIssue?> {
        willDo(validator: Validator<String>.url, key: key, value: value, report: "is invalid" )
    }
}


// MARK: Bundle multiple validations
extension Validation {
    
    /// Execute multiple validation futures in the current thread.
    /// - Parameter validations: An array of validation Future.
    /// - warning:
    ///   Please execute in Thread of SwiftNIO.
    /// - returns:
    ///   An array of issues found in the validation. If the array count is 0, validations is passing.
    func reduce(_ validations: [Future<ValidateIssue?>]) -> Future<[ValidateIssue]> {
        guard let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop else {
            fatalError("The current event loop is not found.")
        }

        return EventLoopFuture.reduce([], validations, eventLoop: eventLoop) { (results, result) -> [ValidateIssue] in
            guard let result = result else { return results }
            var mutableResults = results
            mutableResults.append(result)
            return mutableResults
        }
    }
}


import Infrastructure

// MARK: Set Validation to Future
extension MySQLDatabaseManager {

    /// Query the DB to see if it is a unique username.
    /// - Parameter username: Unique check target.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func isUnique(username: String) -> Future<ValidateIssue?> {
        selectUser(name: username)
            .map {
                guard $0 == nil
                    else { return ValidateIssue(key: "username", report: "has already been taken" ) }
                return nil
            }
    }

    /// Query the DB to see if it is a unique email.
    /// - Parameter email: Unique check target.
    /// - returns:
    ///    Futures that may return issue found as a result of validation.
    func isUnique(email: String) -> Future<ValidateIssue?> {
        selectUser(email: email)
            .map {
                guard $0 == nil
                    else { return ValidateIssue(key: "email", report: "has already been taken" ) }
                return nil
            }
    }
}
