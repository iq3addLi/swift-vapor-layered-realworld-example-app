//
//  CommentEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

/// Representation of Comments table
public final class Comments {
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var id: Int?
    
    /// A body.
    public var body: String
    
    /// A author. It's a `Users`'s id.
    public var author: Int
    
    /// A article. It's a `Articles`'s id.
    public var article: Int
    
    /// A created date.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var createdAt: Date?
    
    /// A updated date.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var updatedAt: Date?

    // MARK: Initializer
    
    /// Default initializer
    /// - Parameters:
    ///   - id: See `id`.
    ///   - body: See `body`.
    ///   - author: See `author`.
    ///   - article: See `article`.
    ///   - createdAt: See `createdAt`.
    ///   - updatedAt: See `updatedAt`.
    public init( id: Int? = nil, body: String, author: Int, article: Int, createdAt: Date? = nil, updatedAt: Date? = nil ) {
        self.id = id
        self.body = body
        self.author = author
        self.article = article
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


// MARK: Create table
extension Comments {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Comments` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `body` text NOT NULL,
              `author` bigint(20) unsigned NOT NULL,
              `article` bigint(20) unsigned NOT NULL,
              `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
              `updatedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
              PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .run()
    }
}


import FluentMySQL

// MARK: Model
extension Comments: MySQLModel {
    /// Table name
    public static var name: String {
        return "Comments"
    }
}

// MARK: Parent/Children relation
extension Comments {

    /// article's detail as `Articles`.
    public var commentedArticle: Parent<Comments, Articles> {
        return parent(\.article)
    }

    /// author's detail as `Users`.
    public var commentedUser: Parent<Comments, Users> {
        return parent(\.author)
    }
}
