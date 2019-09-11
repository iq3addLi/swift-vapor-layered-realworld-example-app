//
//  Article.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor

public struct Article{
    let title: String
    
    public init( title: String ){
        self.title = title
    }
}

extension Article: Encodable, LosslessHTTPBodyRepresentable{
    public func convertToHTTPBody() -> HTTPBody{
        return try! HTTPBody(data: JSONEncoder().encode(self))
    }
}

extension Article: ResponseEncodable{
    public func encode(for request: Request) throws -> EventLoopFuture<Response> {
        let response: Response = request.response( self, as: .json)
        return request.eventLoop.newSucceededFuture(result: response)
    }
}
