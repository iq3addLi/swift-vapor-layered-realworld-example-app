//
//  Favorites.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Favorites table.
public final class Favorites {
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var id: Int?
    
    /// A id of favorite article. It's a `Articles`'s id.
    public var article: Int
    
    /// A id of the user doing the favorite. It's a `Users`'s id.
    public var user: Int
    
    // MARK: Initializer
    
    /// Default initializer
    /// - Parameters:
    ///   - id: See `id`
    ///   - article: See `article`
    ///   - user: See `user`
    public init( id: Int?, article: Int, user: Int ) {
        self.id = id
        self.article = article
        self.user = user
    }
}

// MARK: Create table
extension Favorites {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Favorites` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `article` bigint(20) unsigned NOT NULL,
              `user` bigint(20) unsigned NOT NULL,
              PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .run()
    }
}

import FluentMySQL

// MARK: Model
extension Favorites: MySQLModel {
    /// Table name
    public static var name: String {
        return "Favorites"
    }
}

// MARK: Parent/Children relation
extension Favorites {

    /// A article's detail as `Articles`.
    var favoritedArticle: Parent<Favorites, Articles>? {
        return parent(\.article)
    }

    /// A user's detail as `Users`.
    var favoriteUser: Parent<Favorites, Users>? {
        return parent(\.user)
    }
}
