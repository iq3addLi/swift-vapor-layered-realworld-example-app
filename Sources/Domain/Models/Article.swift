//
//  Article.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

public struct Article{
    
    public let title: String
    public let slug: String
    public let body: String
    public let createdAt: String
    public let updatedAt: String
    public let tagList: [String]
    public let description: String
    public let author: Profile
    public let favorited: Bool
    public let favoritesCount: Int
    
    public init( title: String, slug: String, body: String, createdAt: String, updatedAt: String, tagList: [String], description: String, author: Profile, favorited: Bool, favoritesCount: Int){
        self.title = title
        self.slug = slug
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tagList = tagList
        self.description = description
        self.author = author
        self.favorited = favorited
        self.favoritesCount = favoritesCount
    }
}

import Vapor
extension Article: Content{}

//
//extension Article: Encodable, LosslessHTTPBodyRepresentable{
//    public func convertToHTTPBody() -> HTTPBody{
//        return try! HTTPBody(data: JSONEncoder().encode(self))
//    }
//}
//
//extension Article: ResponseEncodable{
//    public func encode(for request: Request) throws -> EventLoopFuture<Response> {
//        let response: Response = request.response( self, as: .json)
//        return request.eventLoop.newSucceededFuture(result: response)
//    }
//}
