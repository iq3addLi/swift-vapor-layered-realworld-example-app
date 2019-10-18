//
//  ArticleEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

// I don't like the strong nested Protocol and the Model-dependent ORM 😢

import Core // Supply Codable for Date

public final class ArticlesAndAuthorWithFavoritedRow: Codable{
    // Article
    public let id: Int?
    public let slug: String
    public let title: String
    public let description: String
    public let body: String
    public let favoritesCount: Int
    public let favorited: Bool?
    public let createdAt: Date
    public let updatedAt: Date
    
    // Profile
    public let username: String
    public let bio: String
    public let image: String
    public let following: Bool?
    
    // Tags
    public let tagCSV: String?
    
    public init( id: Int?, slug: String, title: String, description: String, body: String, favoritesCount: Int, favorited: Bool?, author: Int, createdAt: Date = Date(), updatedAt: Date = Date(), username: String, bio: String, image: String, following: Bool?, tagCSV: String? ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.description = description
        self.body = body
        self.favoritesCount = favoritesCount
        self.favorited = favorited
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.username = username
        self.bio = bio
        self.image = image
        self.following = following
        
        self.tagCSV = tagCSV
    }
}
