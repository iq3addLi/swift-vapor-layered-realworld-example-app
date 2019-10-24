//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//


public class ArticlesUseCase{
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    public init(){}
}
   

import Async
extension ArticlesUseCase{
    
    public func getArticles( author: String? = nil, feeder: Int? = nil, favorited username: String? = nil, tag: String? = nil, offset: Int? = nil, limit: Int? = nil, readingUserId: Int? = nil) -> Future<MultipleArticlesResponse>{
        
        let condition = { () -> ArticleCondition in
            if let feeder = feeder { return .feed(feeder) }
            if let author = author { return .author(author) }
            if let username = username { return .favorite(username) }
            if let tag = tag { return .tag(tag) }
            return .global
        }()
        
        // Get article from storage
        return conduit.articles(condition: condition, readingUserId: readingUserId, offset: offset, limit: limit)
            .map{ articles in
            MultipleArticlesResponse(articles: articles, articlesCount: articles.count)
        }
    }
    
    
    public func getArticle( slug: String, readingUserId: Int? ) -> Future<SingleArticleResponse>{
        conduit.articles(condition: .slug(slug), readingUserId: readingUserId, offset: nil, limit: nil)
            .map{ articles in
                guard let article = articles.first else{
                    throw Error("Article by slug is not found.")
                }
                return SingleArticleResponse(article: article )
            }
    }
    
    public func postArticle(_ article: NewArticle, author userId: Int ) -> Future<SingleArticleResponse>{
        conduit.addArticle(userId: userId, title: article.title, discription: article._description, body: article.body, tagList: article.tagList ?? [] )
            .map{ article in
                SingleArticleResponse(article: article )
            }
    }
    
    public func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readingUserId: Int? ) -> Future<SingleArticleResponse>{
        conduit.updateArticle(slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: readingUserId)
            .map{ article in
                SingleArticleResponse(article: article)
            }
    }
    
    public func deleteArticle( slug: String ) -> Future<Void>{
        conduit.deleteArticle(slug: slug)
    }

    public func favorite(by userId: Int, for articleSlug: String) -> Future<SingleArticleResponse>{
        conduit.favorite(by: userId, for: articleSlug)
            .map{ article in
                SingleArticleResponse(article: article)
            }
    }
    
    public func unfavorite(by userId: Int, for articleSlug: String) -> Future<SingleArticleResponse>{
        conduit.unfavorite(by: userId, for: articleSlug)
            .map{ article in
                SingleArticleResponse(article: article)
            }
    }
    
    public func getComments( slug: String ) -> Future<MultipleCommentsResponse>{
        conduit.comments(for: slug)
            .map{ comments in
                MultipleCommentsResponse(comments: comments)
            }
    }

    public func postComment( slug: String, body: String, author: Int ) -> Future<SingleCommentResponse>{
        conduit.addComment(for: slug, body: body, author: author)
            .map{ comment in
                SingleCommentResponse(comment: comment)
            }
    }
    
    public func deleteComment( slug: String, id: Int ) -> Future<Void>{
        conduit.deleteComment( for: slug, id: id)
    }
}
