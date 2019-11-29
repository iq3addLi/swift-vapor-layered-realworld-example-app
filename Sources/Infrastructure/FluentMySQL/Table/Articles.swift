//
//  Articles.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

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

import FluentMySQL

extension Articles: MySQLModel {
    // Table name
    public static var name: String {
        return "Articles" // Make explicit
    }

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

//extension Articles: MySQLMigration{
//
//    // Does Not worked in expectly
//    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
//        MySQLDatabase.create(Articles.self, on: connection) { builder in
//            builder.field(for: \.id, isIdentifier: true)
//            builder.field(for: \.slug, type: .text(100), .notNull)
//            builder.field(for: \.title, type: .text(1024), .notNull)
//            builder.field(for: \.description, type: .text, .notNull)
//            builder.field(for: \.body, type: .text, .notNull)
//            builder.field(for: \.author, type: .bigint(20), .notNull)
//            let defaultValueConstraint = MySQLColumnConstraint.default(.value("CURRENT_TIMESTAMP"))
//            builder.field(for: \.createdAt, type: .timestamp, defaultValueConstraint )
//            builder.field(for: \.updatedAt, type: .timestamp, defaultValueConstraint )
//        }
//    }
//}

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
