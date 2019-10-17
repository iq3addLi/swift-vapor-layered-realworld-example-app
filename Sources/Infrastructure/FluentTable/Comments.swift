//
//  CommentEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

import FluentMySQL

public final class Comments{
    public var id: Int?
    public var body: String
    public var author: Int
    public var article: Int
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public init( id: Int? = nil, body: String, author: Int, article: Int, createdAt: Date? = nil, updatedAt: Date? = nil ) {
        self.id = id
        self.body = body
        self.author = author
        self.article = article
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


extension Comments: MySQLModel{
    // Table name
    public static var name: String {
        return "Comments"
    }
}

// Relation
extension Comments {
    
    public var commentedArticle: Parent<Comments, Articles>? {
        return parent(\.article)
    }
    
    public var commentedUser: Parent<Comments, Users>? {
        return parent(\.author)
    }
}

