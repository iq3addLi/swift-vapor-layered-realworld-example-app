//
//  APICollection.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor

public struct APICollection{
    public let method: HTTPMethod
    public let paths: PathComponentsRepresentable
    public let closure: (Request) throws -> Future<Response>
    public let policy: AuthPolicy
    
    public init(method: HTTPMethod,
                paths: PathComponentsRepresentable,
                closure: @escaping (Request) throws -> Future<Response>,
                policy: AuthPolicy = .none){
        self.method = method
        self.paths = paths
        self.closure = closure
        self.policy = policy
    }
}
