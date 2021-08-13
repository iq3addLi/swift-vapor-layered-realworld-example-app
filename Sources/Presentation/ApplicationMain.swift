//
//  ApplicationMain.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Domain

/// The use case for application
private let useCase: ApplicationUseCase = ApplicationUseCase()

/// This application is start here🏃‍♂️
/// - throws:
///  See `ApplicationUseCase.initialize()` and `ApplicationUseCase.launch()`
public func applicationMain() throws {
    
    // Application initialize
    try useCase.initialize()
    
    // Controllers
    let articles = ArticlesController()
    let users = UsersController()
    let profiles = ProfilesController()
    let tags = TagsController()

    // Middlewares
    let authThenSearchUser = AuthenticateThenSearchUserMiddleware()
    let authThenExpandPayload = AuthenticateThenExpandPayloadMiddleware()
    let authOptional = AuthenticateOptionalMiddleware()
    
    // Application routing
    useCase.routing(collections: [
        // User and Authentication
        .init(method: .post, paths: ["users"], closure: users.postUser ),
        .init(method: .post, paths: ["users", "login"], closure: users.login ),
        .init(method: .get, paths: ["user"], closure: users.getUser, middlewares: [authThenSearchUser]  ),
        .init(method: .put, paths: ["user"], closure: users.updateUser, middlewares: [authThenExpandPayload] ),

        // Profile
        .init(method: .get, paths: ["profiles", ":username"], closure: profiles.getProfile, middlewares: [authOptional]  ),
        .init(method: .post, paths: ["profiles", ":username", "follow"], closure: profiles.follow, middlewares: [authThenExpandPayload]  ),
        .init(method: .delete, paths: ["profiles", ":username", "follow"], closure: profiles.unfollow, middlewares: [authThenExpandPayload] ),

        // Articles
        .init(method: .get, paths: ["articles"], closure: articles.getArticles, middlewares: [authOptional] ),
        .init(method: .post, paths: ["articles"], closure: articles.postArticle, middlewares: [authThenExpandPayload] ),
        .init(method: .get, paths: ["articles", ":slug"], closure: articles.getArticle, middlewares: [authOptional] ),
        .init(method: .delete, paths: ["articles", ":slug"], closure: articles.deleteArticle, middlewares: [authThenExpandPayload] ),
        .init(method: .put, paths: ["articles", ":slug"], closure: articles.updateArticle, middlewares: [authThenExpandPayload] ),
        .init(method: .get, paths: ["articles", "feed"], closure: articles.getArticlesMyFeed, middlewares: [authThenExpandPayload] ),

        // Comments
        .init(method: .get, paths: ["articles", ":slug", "comments"], closure: articles.getComments, middlewares: [authOptional] ),
        .init(method: .post, paths: ["articles", ":slug", "comments"], closure: articles.postComment, middlewares: [authThenExpandPayload] ),
        .init(method: .delete, paths: ["articles", ":slug", "comments", ":commentId"], closure: articles.deleteComment, middlewares: [authThenExpandPayload] ),

        // Favorites
        .init(method: .post, paths: ["articles", ":slug", "favorite"], closure: articles.postFavorite, middlewares: [authThenExpandPayload] ),
        .init(method: .delete, paths: ["articles", ":slug", "favorite"], closure: articles.deleteFavorite, middlewares: [authThenExpandPayload] ),

        // Tags
        .init(method: .get, paths: ["tags"], closure: tags.getTags )
    ])

    // Application launching (hostname and port from .env)
    try useCase.launch()
}
