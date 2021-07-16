//
//  ArticleEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

import Foundation

// I don't like the strong nested Protocol and the Model-dependent ORM 😢.
/// Representation of a row combining Articles and authors and favorite information about them.
public final class ArticlesAndAuthorWithFavoritedRow: Codable {
    
    // MARK: Articles

    /// Same as `Articles`'s id.
    public let id: Int?

    /// Same as `Articles`'s slug.
    public let slug: String

    /// Same as `Articles`'s title.
    public let title: String

    /// Same as `Articles`'s description.
    public let description: String

    /// Same as `Articles`'s body.
    public let body: String

    /// Same as `Articles`'s createdAt.
    public let createdAt: Date

    /// Same as `Articles`'s updatedAt.
    public let updatedAt: Date

    
    // MARK: Related to Favorites
    
    /// Total number of `Articles` favorited.
    public let favoritesCount: Int

    /// Whether the person who read this article favorite the article.
    public let favorited: Bool?
    
    
    // MARK: Users

    /// Same as `Users`'s username.
    public let username: String

    /// Same as `Users`'s bio.
    public let bio: String

    /// Same as `Users`'s image.
    public let image: String

    
    // MARK: Related to Follows
    
    /// Whether the author of the article is followed.
    public let following: Bool?

    
    // MARK: Tags

    /// Comma-separated string of tag set attached to article.
    public let tagCSV: String?

    
    // MARK: Initializer
    
    /// Default initializer.
    public init( id: Int?, slug: String, title: String, description: String, body: String, favoritesCount: Int, favorited: Bool?, author: Int, createdAt: Date = Date(), updatedAt: Date = Date(), username: String, bio: String, image: String, following: Bool?, tagCSV: String? ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.description = description
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.favoritesCount = favoritesCount
        self.favorited = favorited
        
        self.username = username
        self.bio = bio
        self.image = image
        
        self.following = following

        self.tagCSV = tagCSV
    }
}
