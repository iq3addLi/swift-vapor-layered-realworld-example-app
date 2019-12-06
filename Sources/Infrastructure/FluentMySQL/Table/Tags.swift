//
//  Tags.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Tags table
public final class Tags {
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var id: Int?
    
    /// A article. It's a `Articles`'s id.
    public var article: Int
    
    /// A tag.
    public var tag: String
    
    // MARK: Initializer
    
    /// Default initializer.
    /// - Parameters:
    ///   - id: See `id`
    ///   - article: See `article`
    ///   - tag: See `tag`
    public init( id: Int?, article: Int, tag: String ) {
        self.id = id
        self.article = article
        self.tag = tag
    }
}


// MARK: Create table
extension Tags {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
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

// MARK: Model
extension Tags: MySQLModel {
    /// Table name.
    public static var name: String {
        return "Tags"
    }
}

// MARK: Parent/Children relation
extension Tags {
    
    /// article's detail as `Articles`.
    var taggedArticle: Parent<Tags, Articles>? {
        return parent(\.article)
    }
}
