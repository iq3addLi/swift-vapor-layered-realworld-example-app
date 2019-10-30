//
//  Articles.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentMySQL

public final class Articles {
    public var id: Int?
    public var slug: String
    public var title: String
    public var description: String
    public var body: String
    public var author: Int
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public init( id: Int?, slug: String, title: String, description: String, body: String, author: Int, createdAt: Date? = nil, updatedAt: Date? = nil ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.description = description
        self.body = body
        self.author = author
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Articles: MySQLModel{
    // Table name
    public static var name: String {
        return "Articles" // Make explicit
    }
}

// Relation
extension Articles {
    
    public var postedUser: Parent<Articles, Users>? {
        return parent(\.author)
    }
    
    public var comments: Children<Articles, Comments> {
        return children(\.article)
    }
    
    public var tags: Children<Articles, Tags> {
        return children(\.article)
    }
}

