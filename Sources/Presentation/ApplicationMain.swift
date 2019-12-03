//
//  ApplicationMain.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Domain

/// All application is start here🏃‍♂️
/// - throws:
///  <#Description#>
public func applciationMain() throws {

    let useCase = ApplicationUseCase()

    // Application initialize
    try useCase.initialize()

    // Controllers
    let articlesController = ArticlesController()
    let usersController = UsersController()
    let profilesController = ProfilesController()
    let tagsController = TagsController()

    // Middlewares
    let authThenSearchUser = AuthenticateThenSearchUserMiddleware()
    let authThenExpandPayload = AuthenticateThenExpandPayloadMiddleware()
    let authOptional = AuthenticateOptionalMiddleware()

    // Application Routing
    useCase.routing(collections: [
        // User and Authentication
        .init(method: .post, paths: ["users"], closure: usersController.postUser ),
        .init(method: .post, paths: ["users", "login"], closure: usersController.login ),
        .init(method: .get, paths: ["user"], closure: usersController.getUser, middlewares: [authThenSearchUser]  ),
        .init(method: .put, paths: ["user"], closure: usersController.updateUser, middlewares: [authThenExpandPayload] ),

        // Profile
        .init(method: .get, paths: ["profiles", String.parameter], closure: profilesController.getProfile, middlewares: [authOptional]  ),
        .init(method: .post, paths: ["profiles", String.parameter, "follow"], closure: profilesController.follow, middlewares: [authThenExpandPayload]  ),
        .init(method: .delete, paths: ["profiles", String.parameter, "follow"], closure: profilesController.unfollow, middlewares: [authThenExpandPayload]  ),

        // Articles
        .init(method: .get, paths: ["articles"], closure: articlesController.getArticles, middlewares: [authOptional] ),
        .init(method: .post, paths: ["articles"], closure: articlesController.postArticle, middlewares: [authThenExpandPayload] ),
        .init(method: .get, paths: ["articles", String.parameter], closure: articlesController.getArticle, middlewares: [authOptional] ),
        .init(method: .delete, paths: ["articles", String.parameter], closure: articlesController.deleteArticle, middlewares: [authThenExpandPayload]  ),
        .init(method: .put, paths: ["articles", String.parameter], closure: articlesController.updateArticle, middlewares: [authThenExpandPayload] ),
        .init(method: .get, paths: ["articles", "feed"], closure: articlesController.getArticlesMyFeed, middlewares: [authThenExpandPayload] ),

        // Comments
        .init(method: .get, paths: ["articles", String.parameter, "comments"], closure: articlesController.getComments, middlewares: [authOptional] ),
        .init(method: .post, paths: ["articles", String.parameter, "comments"], closure: articlesController.postComment, middlewares: [authThenExpandPayload] ),
        .init(method: .delete, paths: ["articles", String.parameter, "comments", Int.parameter], closure: articlesController.deleteComment, middlewares: [authThenExpandPayload] ),

        // Favorites
        .init(method: .post, paths: ["articles", String.parameter, "favorite"], closure: articlesController.postFavorite, middlewares: [authThenExpandPayload] ),
        .init(method: .delete, paths: ["articles", String.parameter, "favorite"], closure: articlesController.deleteFavorite, middlewares: [authThenExpandPayload] ),

        // Tags
        .init(method: .get, paths: ["tags"], closure: tagsController.getTags )
    ])

    // application launch
    try useCase.launch()
}
