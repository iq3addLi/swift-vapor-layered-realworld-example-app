//
//  APICollection.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor

public struct APICollection{
    public let method: HTTPMethodInDomain
    public let paths: PathComponentsRepresentable
    public let closure: (Request) throws -> Future<Response>
    public let middlewares: [Middleware]
    
    public init(method: HTTPMethodInDomain,
                paths: PathComponentsRepresentable,
                closure: @escaping (Request) throws -> Future<Response>,
                middlewares: [Middleware] = []){
        self.method = method
        self.paths = paths
        self.closure = closure
        self.middlewares = middlewares
    }
}
