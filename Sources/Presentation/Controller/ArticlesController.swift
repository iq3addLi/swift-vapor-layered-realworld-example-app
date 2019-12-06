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
    /// Auth optional
    /// ### get query examples
    /// * /articles?offset=100&limit=3)
    /// * /articles?author=johnjacob
    /// * /articles?favorited=jane
    /// * /articles?tag=dragons
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func getArticles(_ request: Request) throws -> Future<Response> {
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        let author = request.query[ String.self, at: "author" ]
        let favorited = request.query[ String.self, at: "favorited" ]
        let tag = request.query[ String.self, at: "tag" ]

        // Get relayed parameter
        let userId = try request.privateContainer.make(VerifiedUserEntity.self).id // Optional

        // Return future
        return useCase.getArticles( author: author, favorited: favorited, tag: tag, offset: offset, limit: limit, readingUserId: userId)
                .map { articles in
                    request.response( articles, as: .json)
                }
    }

    /// POST /articles
    ///
    /// Auth then expand payload
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func postArticle(_ request: Request) throws -> Future<Response> {
        let useCase = self.useCase
        // Get parameter by body
        return try request.content.decode(json: NewArticleRequest.self, using: .custom(dates: .iso8601))
            .flatMap { req -> Future<SingleArticleResponse> in
                // Get relayed parameter
                let userId = try request.privateContainer.make(VerifiedUserEntity.self).id! // Require
                return useCase.postArticle( req.article, author: userId )
            }
            .map { postedArticle in
                request.response( postedArticle, as: .json)
            }
    }

    /// GET /articles/{{slug}}
    ///
    /// Auth optional
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func getArticle(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id // Optional

        // Into domain logic
        return useCase.getArticle(slug: slug, readingUserId: userId)
            .map { article in
                request.response( article, as: .json)
            }
    }

    /// DELETE /articles/{{slug}}
    ///
    /// Auth then expand payload
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func deleteArticle(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Into domain logic
        return useCase.deleteArticle(slug: slug)
            .map {
                request.response( EmptyResponse(), as: .json)
            }
    }

    /// PUT /articles/{{slug}}
    ///
    /// Auth then expand payload
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func updateArticle(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Get relayed parameter
        let userId = try request.privateContainer.make(VerifiedUserEntity.self).id! // Require

        // Get parameter by body
        let useCase = self.useCase
        return try request.content.decode(json: UpdateArticleRequest.self, using: .custom(dates: .iso8601))
            .flatMap { req in
                useCase.updateArticle(slug: slug, title: req.article.title, description: req.article._description, body: req.article.body, tagList: req.article.tagList, readingUserId: userId)
            }
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// GET /articles/feed
    ///
    /// Auth then expand payload
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func getArticlesMyFeed(_ request: Request) throws -> Future<Response> {
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]

        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id // Optional

        return useCase.getArticles(feeder: userId, offset: offset, limit: limit, readingUserId: userId)
            .map { articles in
                request.response( articles, as: .json)
            }
    }

    /// POST /articles/{{slug}}/favorite
    ///
    /// Auth then expand payload
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func postFavorite(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Require

        // Into domain logic
        return useCase.favorite(by: userId, for: slug)
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// DELETE /articles/{{slug}}/favorite
    ///
    /// Auth then expand payload
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func deleteFavorite(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Require

        // Into domain logic
        return useCase.unfavorite(by: userId, for: slug)
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// GET /articles/{{slug}}/comments
    ///
    /// Auth optional
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func getComments(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Into domain logic
        return useCase.getComments(slug: slug)
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// POST /articles/{{slug}}/comments
    ///
    /// Auth then expand payload
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func postComment(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)

        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Require

        // Get parameter by body
        let useCase = self.useCase
        return try request.content.decode(json: NewCommentRequest.self, using: .custom(dates: .iso8601))
            .flatMap { req in
                useCase.postComment(slug: slug, body: req.comment.body, author: userId)
            }
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// DELETE /articles/{{slug}}/comments/{{commentId}}
    ///
    /// Auth required
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func deleteComment(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let slug = try request.parameters.next(String.self)
        let commentId = try request.parameters.next(Int.self)

        // Into domain logic
        return  useCase.deleteComment(slug: slug, id: commentId)
            .map { _ in
                request.response( EmptyResponse(), as: .json)
            }
    }
}
