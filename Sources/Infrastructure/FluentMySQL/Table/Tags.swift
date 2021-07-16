//
//  Tags.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentKit

/// Representation of Tags table
public final class Tags: Model {
    
    public static let schema = "Tags"
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    @ID(custom: .id, generatedBy: .database)
    public var id: Int?
    
    /// A article. It's a `Articles`'s id.
    @Parent(key: "article")
    public var article: Articles
    
    /// A tag.
    @Field(key: "tag")
    public var tag: String
    
    // MARK: Initializer
    
    public init() {}
    
    /// Default initializer.
    /// - Parameters:
    ///   - id: See `id`
    ///   - article: See `article`
    ///   - tag: See `tag`
    public init( id: Int?, article: Int, tag: String ) {
        self.id = id
        self.$article.id = article
        self.tag = tag
    }
}

import MySQLNIO

// MARK: Create table
extension Tags {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
    public static func create(on database: MySQLDatabase) -> EventLoopFuture<Void> {
        database.query("""
            CREATE TABLE IF NOT EXISTS `\(schema)` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `article` bigint(20) unsigned NOT NULL,
              `tag` varchar(256) NOT NULL DEFAULT '',
              PRIMARY KEY (`id`),
              UNIQUE KEY `unique_key` (`article`,`tag`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .map{ _ in return }
    }
}


// MARK: Model
//extension Tags: MySQLModel {
//    /// Table name.
//    public static var name: String {
//        return "Tags"
//    }
//}

// MARK: Parent/Children relation
//extension Tags {
//    
//    /// article's detail as `Articles`.
//    var taggedArticle: Parent<Tags, Articles>? {
//        return parent(\.article)
//    }
//}
