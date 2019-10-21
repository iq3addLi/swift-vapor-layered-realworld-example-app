//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

import Foundation

public class ArticlesUseCase{
    
    let conduit: ConduitRepository = ConduitMySQLRepository()
    
    
    public init(){
    }
    
    public func getArticles( author: String?, favorited username: String?, tag: String?, offset: Int?, limit: Int?) throws -> MultipleArticlesResponse{
        
        let condition = { () -> ArticleCondition in
            if let author = author { return .author(author) }
            if let username = username { return .favorite(username) }
            if let tag = tag { return .tag(tag) }
            return .global
        }()
        
        // TODO: Get userId by JWTToken
        let userId: Int? = nil
        
        // Get article from storage
        let articles = try conduit.articles(condition: condition, readingUserId: userId, offset: offset, limit: limit)
        return MultipleArticlesResponse(articles: articles, articlesCount: articles.count)
    }
    
    public func postArticle(_ article: NewArticle, author userId: Int ) throws -> SingleArticleResponse{
        
        // Add article to storage.
        let added = try conduit.addArticle(userId: userId, title: article.title, discription: article._description, body: article.body, tagList: article.tagList ?? [] )
        
        // Exchange to response value
        return SingleArticleResponse(article: added )
    }

    public func getArticle( slug: String, readingUserId: Int? ) throws -> SingleArticleResponse{
        guard let article =  try conduit.articles(condition: .slug(slug), readingUserId: readingUserId, offset: nil, limit: nil).first else{
            throw Error(reason: "Article not found.")
        }
        return SingleArticleResponse(article: article )
    }

    public func deleteArticle( slug: String ) throws -> Bool{
        return true
    }
    
    public func updateArticle( slug: String ) throws -> SingleArticleResponse?{
        return nil
    }
    
    public func getArticlesByUser( username: String, offset: Int?, limit: Int? ) throws -> MultipleArticlesResponse?{
        return nil
    }
    
    public func favorite( username: String ) throws -> SingleArticleResponse?{
        return nil
    }
    
    public func unfavorite( username: String ) throws -> SingleArticleResponse?{
        return nil
    }
    
    public func getComments( slug: String ) throws -> MultipleCommentsResponse?{
        return nil
    }

    public func postComment( slug: String ) throws -> SingleCommentResponse?{
        return nil
    }

    public func deleteComment( slug: String ) throws -> Bool{
        return true
    }
}
