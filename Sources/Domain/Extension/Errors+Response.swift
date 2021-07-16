//
//  Errors+Response.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/02.
//

import Vapor

// MARK: As Response

/// Extensions required by Domain.
extension AbortError {
    
    /// Convert Vapor.AbortError to Response.
    /// - Parameter request: A request for response.
    /// - throws:
    ///    When HTTPBody generation fails. It cannot happen logically.
    /// - returns:
    ///    A representation of this instance as `Response`.
    func toResponse() throws -> Response {
        // this is an abort error, we should use its status, reason, and headers
        Response(
            status: .init(statusCode: Int(status.code), reasonPhrase: reason),
            headers: .jsonType,
            body: try .init(
                GenericErrorModel(errors: GenericErrorModelErrors(body: [reason]))
            )
        )
    }
}


/// Extensions required by Domain.
extension ValidationError {
    
    /// Convert validation errors to Response.
    /// - Parameter request: A request for response.
    /// - throws:
    ///    When HTTPBody generation fails. It cannot happen logically.
    /// - returns:
    ///    A representation of this instance as `Response`.
    func toResponse() throws -> Response {
        Response(
            status: .badRequest,
            headers: .jsonType,
            body: try .init( self )
        )
    }
}


/// Extensions required by Domain.
extension Error {
    
    /// Convert Domain.Error to Response.
    /// - Parameter request: A request for response.
    /// - throws:
    ///    When HTTPBody generation fails. It cannot happen logically.
    /// - returns:
    ///    A representation of this instance as `Response`.
    func toResponse() throws -> Response {
        // reason property should be collected as a log
        Response(
            status: .init(statusCode: status, reasonPhrase: reason),
            headers: .jsonType,
            body: try .init( HTTPErrorResponse("\(status)", error: reason) )
        )
    }
}

