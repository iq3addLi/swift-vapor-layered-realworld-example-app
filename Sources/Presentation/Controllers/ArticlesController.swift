//
//  ArticlesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct ArticlesController {
    
    let useCase = ArticlesUseCase()
    
    // GET /articles
    //     /articles?offset=100&limit=3)
    //     /articles?author=johnjacob
    //     /articles?favorited=jane
    //     /articles?tag=dragons
    //  <Auth optional>
    func getArticles(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        let author = request.query[ String.self, at: "author" ]
        let favorited = request.query[ String.self, at: "favorited" ]
        let tag = request.query[ String.self, at: "tag" ]
        
        // Get relayed parameter
        let userId = try request.privateContainer.make(VerifiedUserEntity.self).id // Optional
        
        // Into domain logic
        let articles = try useCase.getArticles( author: author, favorited: favorited, tag: tag, offset: offset, limit: limit, readingUserId: userId)
        
        // Success
        return try request.response( articles , as: .json).encode(for: request)
    }
    
    // POST /articles
    //  <Auth then expand payload>
    func postArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by body
        let req = try request.content.decode(json: NewArticleRequest.self, using: JSONDecoder()).wait()
        
        // Get relayed parameter
        let userId = try request.privateContainer.make(VerifiedUserEntity.self).id! // Require
        
        // Into domain logic
        let postedArticle = try self.useCase.postArticle( req.article, author: userId )
        
        // Success
        return request.response( postedArticle, as: .json).encode(status: .ok, for: request)
    }
    
    // GET /articles/{{slug}}
    //  <Auth optional>
    func getArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id // Optional
        
        // Into domain logic
        let article = try useCase.getArticle(slug: slug, readingUserId: userId)
        
        // Success
        return request.response( article , as: .json).encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}
    //  <Auth then expand payload>
    func deleteArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Into domain logic
        try useCase.deleteArticle(slug: slug)
        
        // Success
        return request.response().encode(status: .ok, for: request)
    }
    
    // PUT /articles/{{slug}}
    //  <Auth then expand payload>
    func updateArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Get parameter by body
        let article = try request.content.decode(json: UpdateArticleRequest.self, using: JSONDecoder()).wait().article
        
        // Get relayed parameter
        let userId = try request.privateContainer.make(VerifiedUserEntity.self).id! // Require
        
        // Into domain logic
        let response = try useCase.updateArticle(slug: slug, title: article.title, description: article._description, body: article.body, tagList: article.tagList, readingUserId: userId)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    

    // GET /articles/feed
    //  <Auth then expand payload>
    func getArticlesMyFeed(_ request: Request) throws -> Future<Response> {
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id // Optional
        
        // Into domain logic
        let articles = try useCase.getArticles(feeder: userId, offset: offset, limit: limit, readingUserId: userId)
        
        // Success
        return request.response( articles , as: .json).encode(status: .ok, for: request)
    }
    
    // POST /articles/{{slug}}/favorite
    //  <Auth then expand payload>
    func postFavorite(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Required
        
        // Into domain logic
        let response = try useCase.favorite(by: userId, for: slug)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}/favorite
    //  <Auth then expand payload>
    func deleteFavorite(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Required
        
        // Into domain logic
        let response = try useCase.unfavorite(by: userId, for: slug)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // GET /articles/{{slug}}/comments
    //  <Auth optional>
    func getComments(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Into domain logic
        let response = try useCase.getComments(slug: slug)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // POST /articles/{{slug}}/comments
    //  <Auth then expand payload>
    func postComment(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        
        // Get parameter by body
        let comment = try request.content.decode(json: NewCommentRequest.self, using: JSONDecoder()).wait().comment
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Required
        
        // Into domain logic
        let response = try useCase.postComment(slug: slug, body: comment.body, author: userId)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}/comments/{{commentId}}
    //  <Auth required>
    func deleteComment(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        let commentId = try request.parameters.next(Int.self)
        
        // Into domain logic
        try useCase.deleteComment(slug: slug, id: commentId)
        return request.response().encode(status: .ok, for: request)
    }
    
}
