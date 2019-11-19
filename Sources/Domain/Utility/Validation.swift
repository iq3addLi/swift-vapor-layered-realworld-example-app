//
//  Validation.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/18.
//

import Async
import Validation

class Validation{
    static func `do`( validator: Validator<String>, key: String, value: String, report: String ) -> Future<ValidateIssue?>{
        guard let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("The current event loop is not found.")
        }

        return eventLoop.submit { () -> ValidateIssue? in
            do { try validator.validate(value) }
            catch { return ValidateIssue(key: key, report: report) }
            return nil
        }
    }
}

extension Domain.Validation{
    static func count(_ range: PartialRangeFrom<Int>, key: String, value: String ) -> Future<ValidateIssue?>{
        Self.do(validator: Validator<String>.count(range), key: key, value: value, report: "is too short (minimum is \(range.lowerBound) characters)")
    }
    
    static func count(_ range: PartialRangeThrough<Int>, key: String, value: String ) -> Future<ValidateIssue?>{
        Self.do(validator: Validator<String>.count(range), key: key, value: value, report: "is too long (maximum is \(range.upperBound) characters)")
    }
    
    static func blank( key: String, value: String ) -> Future<ValidateIssue?>{
        Self.do(validator: !Validator<String>.empty, key: key, value: value, report: "can't be blank")
    }
    
    static func email(_ value: String ) -> Future<ValidateIssue?>{
        Self.do(validator: Validator<String>.email, key: "email", value: value, report: "is invalid" )
    }
    
    static func url( key: String, value: String ) -> Future<ValidateIssue?>{
        Self.do(validator: Validator<String>.url, key: key, value: value, report: "is invalid" )
    }
}

extension Domain.Validation{

    static func reduce(_ validations: [Future<ValidateIssue?>]) -> Future<[ValidateIssue]> {
        guard let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop else{
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
import FluentMySQL

extension MySQLDatabaseManager{

    func isUnique(username: String) -> Future<ValidateIssue?>{
        self.connectionOnCurrentEventLoop().flatMap { connection in
            Users.query(on: connection)
                .filter(\Users.username == username)
                .all()
                .map{
                    guard $0.first == nil
                        else{ return ValidateIssue(key: "username", report: "has already been taken" ) }
                    return nil
                }
        }
    }
    
    func isUnique(email: String) -> Future<ValidateIssue?>{
        self.connectionOnCurrentEventLoop().flatMap { connection in
            Users.query(on: connection)
                .filter(\Users.email == email)
                .all()
                .map{
                    guard $0.first == nil
                        else{ return ValidateIssue(key: "email", report: "has already been taken" ) }
                    return nil
                }
        }
    }
}
