//
//  ArticleEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

// I don't like the deep nested Protocol and the Model-dependent ORM 😢
//import FluentMySQL
//
//
//public final class ArticleEntity: MySQLModel{
//    public var id: Int?
//
//    public let title: String
//}
//
//extension ArticleEntity: Migration{}

public final class Articles {
    public var slug: String
    public var title: String
    public var description: String
    public var body: String
    public var favoritesCount: Int
    public var comments: [Int]
    public var tagList: [String]
    public var author: Int
    
    public init( slug: String, title: String, description: String, body: String, favoritesCount: Int, comments: [Int] = [], tagList: [String] = [], author: Int ) {
        self.slug = slug
        self.title = title
        self.description = description
        self.body = body
        self.favoritesCount = favoritesCount
        self.comments = comments
        self.tagList = tagList
        self.author = author
    }
}

//slug: {type: String, lowercase: true, unique: true},
//title: String,
//description: String,
//body: String,
//favoritesCount: {type: Number, default: 0},
//comments: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Comment' }],
//tagList: [{ type: String }],
//author: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
