//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

import Foundation

public class ArticlesUseCase{
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    public init(){}
    
    public func getArticles( author: String? = nil, feeder: Int? = nil, favorited username: String? = nil, tag: String? = nil, offset: Int? = nil, limit: Int? = nil, readingUserId: Int? = nil) throws -> MultipleArticlesResponse{
        
        let condition = { () -> ArticleCondition in
            if let feeder = feeder { return .feed(feeder) }
            if let author = author { return .author(author) }
            if let username = username { return .favorite(username) }
            if let tag = tag { return .tag(tag) }
            return .global
        }()
        
        // Get article from storage
        let articles = try conduit.articles(condition: condition, readingUserId: readingUserId, offset: offset, limit: limit)
        return MultipleArticlesResponse(articles: articles, articlesCount: articles.count)
    }
    
    public func getArticle( slug: String, readingUserId: Int? ) throws -> SingleArticleResponse{
        guard let article =  try conduit.articles(condition: .slug(slug), readingUserId: readingUserId, offset: nil, limit: nil).first else{
            throw Error( "Article not found.")
        }
        return SingleArticleResponse(article: article )
    }
    
    public func postArticle(_ article: NewArticle, author userId: Int ) throws -> SingleArticleResponse{

        // Exchange to response value
        return SingleArticleResponse(article:
            try conduit.addArticle(userId: userId, title: article.title, discription: article._description, body: article.body, tagList: article.tagList ?? [] )
        )
    }

    public func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readingUserId: Int? ) throws -> SingleArticleResponse{
        return SingleArticleResponse(article:
            try conduit.updateArticle(slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: readingUserId)
        )
    }
    
    public func deleteArticle( slug: String ) throws{
        try conduit.deleteArticle(slug: slug)
    }
    
    public func favorite(by userId: Int, for articleSlug: String) throws -> SingleArticleResponse{
        return SingleArticleResponse(article:
            try conduit.favorite(by: userId, for: articleSlug)
        )
    }
    
    public func unfavorite(by userId: Int, for articleSlug: String) throws -> SingleArticleResponse{
        return SingleArticleResponse(article:
            try conduit.unfavorite(by: userId, for: articleSlug)
        )
    }
    
    public func getComments( slug: String ) throws -> MultipleCommentsResponse{
        return MultipleCommentsResponse(comments:
            try conduit.comments(for: slug)
        )
    }

    public func postComment( slug: String, body: String, author: Int ) throws -> SingleCommentResponse{
        return SingleCommentResponse(comment:
            try conduit.addComment(for: slug, body: body, author: author)
        )
    }

    public func deleteComment( slug: String, id: Int ) throws{
        try conduit.deleteComment( for: slug, id: id)
    }
    
    
}
