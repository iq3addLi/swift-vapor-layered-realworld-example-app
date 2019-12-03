//
//  Tags.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Tags table
public final class Tags {
    public var id: Int?
    public var article: Int
    public var tag: String
    public init( id: Int?, article: Int, tag: String ) {
        self.id = id
        self.article = article
        self.tag = tag
    }
}


extension Tags {
    
    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Tags` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `article` bigint(20) unsigned NOT NULL,
              `tag` varchar(256) NOT NULL DEFAULT '',
              PRIMARY KEY (`id`),
              UNIQUE KEY `unique_key` (`article`,`tag`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .run()
    }
}


import FluentMySQL

extension Tags: MySQLModel {
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
