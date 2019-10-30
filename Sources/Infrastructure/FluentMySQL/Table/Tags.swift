//
//  Tags.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentMySQL

public final class Tags{
    public var id: Int?
    public var article: Int
    public var tag: String
    public init( id: Int?, article: Int, tag: String ) {
        self.id = id
        self.article = article
        self.tag = tag
    }
}


extension Tags: MySQLModel{
    // Table name
    public static var name: String {
        return "Tags"
    }
}

// Relation
extension Tags {
    var taggedArticle: Parent<Tags, Articles>? {
        return parent(\.article)
    }
}

