//
//  Articles.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Articles table
public final class Articles {
    
    // MARK: Properties
    
    public var id: Int?
    public var slug: String
    public var title: String
    public var description: String
    public var body: String
    public var author: Int
    public var createdAt: Date?
    public var updatedAt: Date?

    // MARK: Functions
    
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

extension Articles {
    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Articles` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `slug` varchar(100) NOT NULL,
              `title` varchar(1024) NOT NULL,
              `description` text NOT NULL,
              `body` text NOT NULL,
              `author` bigint(20) unsigned NOT NULL,
              `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
              `updatedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
              PRIMARY KEY (`id`),
              UNIQUE KEY `slug_UNIQUE` (`slug`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .run()
    }
}


import FluentMySQL

extension Articles: MySQLModel {
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
