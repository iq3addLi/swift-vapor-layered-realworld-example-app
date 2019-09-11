//
//  APICollection.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Foundation
import Vapor

public struct APICollection{
    public let method: HTTPMethod
    public let paths: PathComponentsRepresentable
    public let closure: (Request) throws -> String
    
    public init(method: HTTPMethod, paths: PathComponentsRepresentable, closure: @escaping (Request) throws -> String){
        self.method = method
        self.paths = paths
        self.closure = closure
    }
}
