//
//  ArticleEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

// I don't like the strong nested Protocol and the Model-dependent ORM 😢

import Core // Supply Codable for Date

/// dummy comment
public final class ArticlesAndAuthorWithFavoritedRow: Codable {
    // Article

    // dummy comment
    public let id: Int?

    // dummy comment
    public let slug: String

    // dummy comment
    public let title: String

    // dummy comment
    public let description: String

    // dummy comment
    public let body: String

    // dummy comment
    public let favoritesCount: Int

    // dummy comment
    public let favorited: Bool?

    // dummy comment
    public let createdAt: Date

    // dummy comment
    public let updatedAt: Date

    // Profile

    // dummy comment
    public let username: String

    // dummy comment
    public let bio: String

    // dummy comment
    public let image: String

    // dummy comment
    public let following: Bool?

    // Tags

    // dummy comment
    public let tagCSV: String?

    // dummy comment
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
