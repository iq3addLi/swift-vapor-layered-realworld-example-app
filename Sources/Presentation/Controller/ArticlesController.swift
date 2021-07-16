//
//  ArticlesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Domain
import Vapor

/// Controller For Article processing.
struct ArticlesController {

    // MARK: Properties
    
    /// The use case for articles.
    ///
    /// See `ArticlesUseCase`.
    private let useCase = ArticlesUseCase()

    
    // MARK: Controller for articles
    
    /// GET /articles
    ///
    /// Auth optional.
    /// ### get query examples
    /// * /articles?offset=100&limit=3)
    /// * /articles?author=johnjacob
    /// * /articles?favorited=jane
    /// * /articles?tag=dragons
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    See `Container.make()`
    /// - returns:
    ///    The `Future` that returns `Response`.
    func getArticles(_ request: Request) throws -> Future<Response> {
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        let author = request.query[ String.self, at: "author" ]
        let favorited = request.query[ String.self, at: "favorited" ]
        let tag = request.query[ String.self, at: "tag" ]

        // Get relayed parameter
        let userId = request.storage[VerifiedUserEntity.Key.self]?.id // Optional

        // Return future
        return useCase.getArticles( author: author, favorited: favorited, tag: tag, offset: offset, limit: limit, readingUserId: userId)
            .flatMapThrowing { articles in
                try Response( articles )
            }
    }

    /// POST /articles
    ///
    /// Auth then expand payload.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    Normally, no error is thrown in this function. 
    /// - returns:
    ///    The `Future` that returns `Response`.
    func postArticle(_ request: Request) throws -> Future<Response> {
 
        // Get parameter by body
        let req = try request.content.decode(NewArticleRequest.self, using: JSONDecoder.custom(dates: .iso8601))
        
        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.") // Require
        }
        
        return useCase.postArticle( req.article, author: userId ).flatMapThrowing { article in
            try Response( article )
        }
    }

    /// GET /articles/:slug
    ///
    /// Auth optional.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func getArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }

        // Get relayed parameter
        let userId = request.storage[VerifiedUserEntity.Key.self]?.id // Optional

        // Into domain logic
        return useCase.getArticle(slug: slug, readingUserId: userId)
            .flatMapThrowing { article in
                try Response( article )
            }
    }

    /// DELETE /articles/:slug
    ///
    /// Auth then expand payload
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func deleteArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }

        // Into domain logic
        return useCase.deleteArticle(slug: slug)
            .flatMapThrowing {
                try Response( EmptyResponse() )
            }
    }

    /// PUT /articles/:slug
    ///
    /// Auth then expand payload
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func updateArticle(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }
        
        // Get parameter by body
        let req = try request.content.decode(UpdateArticleRequest.self, using: JSONDecoder.custom(dates: .iso8601))
        
        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.")  // Require
        }
        
        return useCase.updateArticle(slug: slug, title: req.article.title, description: req.article._description, body: req.article.body, tagList: req.article.tagList, readingUserId: userId)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// GET /articles/feed
    ///
    /// Auth then expand payload
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func getArticlesMyFeed(_ request: Request) throws -> Future<Response> {
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]

        // Get relayed parameter
        let userId = request.storage[VerifiedUserEntity.Key.self]?.id // Optional

        return useCase.getArticles(feeder: userId, offset: offset, limit: limit, readingUserId: userId)
            .flatMapThrowing { articles in
                try Response( articles )
            }
    }

    /// POST /articles/:slug/favorite
    ///
    /// Auth then expand payload
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func postFavorite(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }

        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.")  // Require
        }

        // Into domain logic
        return useCase.favorite(by: userId, for: slug)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// DELETE /articles/:slug/favorite
    ///
    /// Auth then expand payload
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func deleteFavorite(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }

        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.")  // Require
        }

        // Into domain logic
        return useCase.unfavorite(by: userId, for: slug)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// GET /articles/:slug/comments
    ///
    /// Auth optional
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func getComments(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }

        // Into domain logic
        return useCase.getComments(slug: slug)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// POST /articles/:slug/comments
    ///
    /// Auth then expand payload.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func postComment(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let slug = request.parameters.get("slug") else{
            fatalError("A Request is not contain to slug.")
        }

        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.")  // Require
        }

        // Get parameter by body
        let req = try request.content.decode(NewCommentRequest.self, using: JSONDecoder.custom(dates: .iso8601))
        
        return useCase.postComment(slug: slug, body: req.comment.body, author: userId)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// DELETE /articles/:slug/comments/:commentId
    ///
    /// Auth required.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func deleteComment(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        guard
            let slug = request.parameters.get("slug"),
            let str = request.parameters.get("commentId"),
            let commentId = Int(str)
        else{
            fatalError("URL parameters contains mistake.")
        }
        
        return  useCase.deleteComment(slug: slug, id: commentId)
            .flatMapThrowing { _ in
                try Response( EmptyResponse() )
            }
    }
}
