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
    func toResponse(for request: Request) throws -> Response {
        // this is an abort error, we should use its status, reason, and headers
        let response = request.response(http: .init(status: status, headers: headers))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(
            GenericErrorModel(errors: GenericErrorModelErrors(body: [reason]))
        ))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }
}

// MARK: As Response

/// Extensions required by Domain.
extension Debuggable {
    
    /// Convert Core.Debuggable to Response.
    /// - Parameter request: A request for response.
    /// - throws:
    ///    When HTTPBody generation fails. It cannot happen logically.
    /// - returns:
    ///    A representation of this instance as `Response`.
    func toResponse(for request: Request) throws -> Response {
        // if not release mode, and error is debuggable, provide debug
        // info directly to the developer
        let response = request.response(http: .init(status: .internalServerError, headers: [:]))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(
            GenericErrorModel(errors: GenericErrorModelErrors(body: [reason]))
        ))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response

    }
}

// MARK: As Response

/// Extensions required by Domain.
extension ValidationError {
    
    /// Convert validation errors to Response.
    /// - Parameter request: A request for response.
    /// - throws:
    ///    When HTTPBody generation fails. It cannot happen logically.
    /// - returns:
    ///    A representation of this instance as `Response`.
    func toResponse(for request: Request) throws -> Response {
        let response = request.response(http: .init(status: .badRequest, headers: [:]))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(self))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }
}


// MARK: As Response

/// Extensions required by Domain.
extension Error {
    
    /// Convert Domain.Error to Response.
    /// - Parameter request: A request for response.
    /// - throws:
    ///    When HTTPBody generation fails. It cannot happen logically.
    /// - returns:
    ///    A representation of this instance as `Response`.
    func toResponse(for request: Request) throws -> Response {
        // reason property should be collected as a log
        let httpStatus = HTTPResponseStatus(statusCode: status)
        let response = request.response(http: .init(status: httpStatus, headers: [:]))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(
            HTTPErrorResponse("\(httpStatus.code)", error: httpStatus.reasonPhrase)
        ))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }
}

