//
//  Favorites.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Favorites table
public final class Favorites {
    
    // MARK: Properties
    
    public var id: Int?
    public var article: Int
    public var user: Int
    
    // MARK: Functions
    
    public init( id: Int?, article: Int, user: Int ) {
        self.id = id
        self.article = article
        self.user = user
    }
}

extension Favorites {
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

extension Favorites: MySQLModel {
    // Table name
    public static var name: String {
        return "Favorites"
    }
}

// Relation
extension Favorites {

    var favoritedArticle: Parent<Favorites, Articles>? {
        return parent(\.article)
    }

    var favoriteUser: Parent<Favorites, Users>? {
        return parent(\.user)
    }
}
