//
//  Articles.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Articles table.
///
/// Note that no one depends on anyone at the time of the declaration. This is POJO in Java. Fluent's added functionality is Protocol, so it will be easy to remove and move to another ORMappeer. If possible, it is desirable not even to depend on Protocol.
/// ### Extras
/// Realm is an excellent product, but from this point of view it is very disappointing.😭
public final class Articles {
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var id: Int?
    
    /// A slug. https://en.wikipedia.org/wiki/Clean_URL#Slug
    public var slug: String
    
    /// A title.
    public var title: String
    
    /// A description.
    public var description: String
    
    /// A body.
    public var body: String
    
    /// A author. It's a `Users`'s id.
    public var author: Int
    
    /// A created date.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var createdAt: Date?
    
    /// A updated date.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var updatedAt: Date?

    
    // MARK: Initializer
    
    /// Default initializer.
    /// - Parameters:
    ///   - id: A id.
    ///   - slug: A slug.
    ///   - title: A title.
    ///   - description: A description.
    ///   - body: A body.
    ///   - author: A author.
    ///   - createdAt: A created date.
    ///   - updatedAt: A updated date.
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


// MARK: Create table

extension Articles {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
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

// MARK: Model
extension Articles: MySQLModel {
    /// Table name.
    public static var name: String {
        return "Articles" // Make explicit
    }
}

// MARK: Parent/Children relation
extension Articles {

    /// author's detail as `Users`.
    public var postedUser: Parent<Articles, Users>? {
        return parent(\.author)
    }

    /// Comments on articles as `Comments`.
    public var comments: Children<Articles, Comments> {
        return children(\.article)
    }

    /// Tags on articles as `Tags`.
    public var tags: Children<Articles, Tags> {
        return children(\.article)
    }
}
