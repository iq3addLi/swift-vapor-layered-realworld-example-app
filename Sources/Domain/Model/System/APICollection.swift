//
//  APICollection.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor

/// dummy comment
public struct APICollection {

    /// dummy comment
    public let method: HTTPMethodInDomain

    /// dummy comment
    public let paths: PathComponentsRepresentable

    /// dummy comment
    public let closure: (Request) throws -> Future<Response>

    /// dummy comment
    public let middlewares: [Middleware]

    /// dummy comment
    public init(method: HTTPMethodInDomain,
                paths: PathComponentsRepresentable,
                closure: @escaping (Request) throws -> Future<Response>,
                middlewares: [Middleware] = []) {
        self.method = method
        self.paths = paths
        self.closure = closure
        self.middlewares = middlewares
    }
}
