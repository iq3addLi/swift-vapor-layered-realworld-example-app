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
public func applciationMain() throws{
    
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
        APICollection(method: .post, paths: ["users"], closure: usersController.postUser ),
        APICollection(method: .post, paths: ["users","login"], closure: usersController.login ),
        APICollection(method: .get, paths: ["user"], closure: usersController.getUser, middlewares: [authThenSearchUser]  ),
        APICollection(method: .put, paths: ["user"], closure: usersController.updateUser, middlewares: [authThenExpandPayload] ),
        
        // Profile
        APICollection(method: .get, paths: ["profiles", String.parameter], closure: profilesController.getProfile, middlewares: [authOptional]  ),
        APICollection(method: .post, paths: ["profiles", String.parameter, "follow"], closure: profilesController.follow, middlewares: [authThenExpandPayload]  ),
        APICollection(method: .delete, paths: ["profiles", String.parameter, "follow"], closure: profilesController.unfollow, middlewares: [authThenExpandPayload]  ),
        
        // Articles
        APICollection(method: .get, paths: ["articles"], closure: articlesController.getArticles, middlewares: [authOptional] ),
        APICollection(method: .post, paths: ["articles"], closure: articlesController.postArticle, middlewares: [authThenExpandPayload] ),
        APICollection(method: .get, paths: ["articles", String.parameter], closure: articlesController.getArticle, middlewares: [authOptional] ),
        APICollection(method: .delete, paths: ["articles", String.parameter], closure: articlesController.deleteArticle, middlewares: [authThenExpandPayload]  ),
        APICollection(method: .put, paths: ["articles", String.parameter], closure: articlesController.updateArticle, middlewares: [authThenExpandPayload] ),
        APICollection(method: .get, paths: ["articles", "feed"], closure: articlesController.getArticlesMyFeed, middlewares: [authThenExpandPayload] ),

        // Comments
        APICollection(method: .get, paths: ["articles", String.parameter, "comments"], closure: articlesController.getComments, middlewares: [authOptional] ),
        APICollection(method: .post, paths: ["articles", String.parameter, "comments"], closure: articlesController.postComment, middlewares: [authThenExpandPayload] ),
        APICollection(method: .delete, paths: ["articles", String.parameter, "comments", Int.parameter], closure: articlesController.deleteComment, middlewares: [authThenExpandPayload] ),
        
        // Favorites
        APICollection(method: .post, paths: ["articles", String.parameter, "favorite"], closure: articlesController.postFavorite, middlewares: [authThenExpandPayload] ),
        APICollection(method: .delete, paths: ["articles", String.parameter, "favorite"], closure: articlesController.deleteFavorite, middlewares: [authThenExpandPayload] ),
        
        // Tags
        APICollection(method: .get, paths: ["tags"], closure: tagsController.getTags ),
    ])
    
    // application launch
    try useCase.launch()
}

