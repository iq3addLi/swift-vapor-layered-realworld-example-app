//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

import Foundation

public class ArticlesUseCase{
    
    let conduit: ConduitRepository = ConduitInMemoryRepository()
    
    public init(){
    }
    
    public func getArticles( offset: Int?, limit: Int?, author: String?, favorited username: String?, tag: String? ) throws -> MultipleArticlesResponse?{
        // Get article from storage
        let articles = try conduit.getArticles(offset: offset, limit: limit, author: author, favorited: username, tag: tag)
        return MultipleArticlesResponse(articles: articles, articlesCount: articles.count)
    }
    
    public func postArticle(_ article: NewArticle, author userId: Int ) throws -> SingleArticleResponse?{
        
        // Add article to storage.
        guard let added = try conduit.addArticle(userId: userId, title: article.title, discription: article._description, body: article.body, tagList: article.tagList ?? [] ) else{
            return nil // database error
        }
        
        // Exchange to response value
        return SingleArticleResponse(article: added )
    }

    public func getArticle( slug: String ) throws -> SingleArticleResponse?{
        return nil
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
