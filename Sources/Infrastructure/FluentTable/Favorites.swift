//
//  Favorites.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentMySQL

public final class Favorites{
    public var id: Int?
    public var article: Int
    public var user: Int
    public init( id: Int?, article: Int, user: Int ) {
        self.id = id
        self.article = article
        self.user = user
    }
}


extension Favorites: MySQLModel{
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
