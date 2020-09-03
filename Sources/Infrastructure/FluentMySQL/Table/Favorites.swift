//
//  Favorites.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentKit

/// Representation of Favorites table.
public final class Favorites: Model {
    
    public static let schema = "favorites"
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    @ID(custom: .id, generatedBy: .database)
    public var id: Int?
    
    /// A id of favorite article. It's a `Articles`'s id.
    @Parent(key: "article")
    public var article: Articles
    
    /// A id of the user doing the favorite. It's a `Users`'s id.
    @Parent(key: "user")
    public var user: Users
    
    // MARK: Initializer
    
    public init() { }
    
    /// Default initializer
    /// - Parameters:
    ///   - id: See `id`
    ///   - article: See `article`
    ///   - user: See `user`
    public init( id: Int?, article: Int, user: Int ) {
        self.id = id
        self.$article.id = article
        self.$user.id = user
    }
}


import MySQLNIO

// MARK: Create table
extension Favorites {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
    public static func create(on database: MySQLDatabase) -> EventLoopFuture<Void> {
        database.query("""
            CREATE TABLE IF NOT EXISTS `Favorites` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `article` bigint(20) unsigned NOT NULL,
              `user` bigint(20) unsigned NOT NULL,
              PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .map{ _ in return }
    }
}


// MARK: Model
//extension Favorites: MySQLModel {
//    /// Table name
//    public static var name: String {
//        return "Favorites"
//    }
//}

// MARK: Parent/Children relation
//extension Favorites {
//
//    /// A article's detail as `Articles`.
//    var favoritedArticle: Parent<Favorites, Articles>? {
//        return parent(\.article)
//    }
//
//    /// A user's detail as `Users`.
//    var favoriteUser: Parent<Favorites, Users>? {
//        return parent(\.user)
//    }
//}
