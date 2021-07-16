//
//  APICollection.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor

/// Order for defining routing.
///
/// It was defined as a specification when ordering routing from the presentation layer to the domain layer.
/// ### Note
/// If possible, I wanted to define this class as an abstract order that does not depend on the framework, but I gave up it because it was difficult in Vapor.
public struct APICollection {

    // MARK: Properties
    
    /// HTTPMethod to which API responds.
    public let method: HTTPMethodInDomain

    /// See `PathComponentsRepresentable`.
    public let paths: [PathComponent]

    /// API processing.
    public let closure: (Request) throws -> Future<Response>

    /// Middleware that performs processing between Framework and Controller.
    public let middlewares: [Middleware]

    // MARK: Initializer
    
    /// Default initializer.
    /// - Parameters:
    ///   - method: HTTPMethod to which API responds.
    ///   - paths: See `PathComponent`.
    ///   - closure: API processing.
    ///   - middlewares: Middleware that performs processing between Framework and Controller.
    public init(method: HTTPMethodInDomain,
                paths: [PathComponent],
                closure: @escaping (Request) throws -> Future<Response>,
                middlewares: [Middleware] = []) {
        self.method = method
        self.paths = paths
        self.closure = closure
        self.middlewares = middlewares
    }
}
