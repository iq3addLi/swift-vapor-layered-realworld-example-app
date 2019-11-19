//
//  CommentEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//


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

import FluentMySQL

extension Comments: MySQLModel{
    // Table name
    public static var name: String {
        return "Comments"
    }
    
    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Comments` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `body` text NOT NULL,
              `author` bigint(20) unsigned NOT NULL,
              `article` bigint(20) unsigned NOT NULL,
              `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
              `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
              PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .run()
    }
}

// extension Comments: MySQLMigration{}

// Relation
extension Comments {
    
    public var commentedArticle: Parent<Comments, Articles> {
        return parent(\.article)
    }
    
    public var commentedUser: Parent<Comments, Users> {
        return parent(\.author)
    }
}

