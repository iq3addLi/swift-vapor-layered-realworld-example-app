//
//  Application.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public func applciationMain() throws{
    
    let useCase = ApplicationUseCase()
    
    // Application initialize
    try useCase.initialize()
    
    let articlesController = ArticlesController()
    let usersController = UsersController()
    let profilesController = ProfilesController()
    let tagsController = TagsController()
    
    // Application Routing
    useCase.routing(collections: [
        // User and Authentication
        APICollection(method: .POST, paths: ["users"], closure: usersController.postUser ),
        APICollection(method: .POST, paths: ["users","login"], closure: usersController.login ),
        APICollection(method: .GET, paths: ["user"], closure: usersController.getUser ),
        APICollection(method: .PUT, paths: ["user"], closure: usersController.updateUser ),
        
        // Profile
        APICollection(method: .GET, paths: ["profiles", String.parameter], closure: profilesController.getProfile ),
        APICollection(method: .POST, paths: ["profiles", String.parameter, "follow"], closure: profilesController.follow ),
        APICollection(method: .DELETE, paths: ["profiles", String.parameter, "follow"], closure: profilesController.unfollow ),
        
        // Articles
        APICollection(method: .GET, paths: ["articles"], closure: articlesController.getArticles ),
        APICollection(method: .POST, paths: ["articles"], closure: articlesController.postArticle ),
        APICollection(method: .GET, paths: ["articles", String.parameter], closure: articlesController.getArticle ),
        APICollection(method: .DELETE, paths: ["articles", String.parameter], closure: articlesController.deleteArticle ),
        APICollection(method: .PUT, paths: ["articles", String.parameter], closure: articlesController.updateArticle ),
        APICollection(method: .GET, paths: ["articles", "feed"], closure: articlesController.getArticlesMyFeed ),

        // Comments
        APICollection(method: .GET, paths: ["articles", String.parameter, "comments"], closure: articlesController.getComments ),
        APICollection(method: .POST, paths: ["articles", String.parameter, "comments"], closure: articlesController.postComment ),
        APICollection(method: .DELETE, paths: ["articles", String.parameter, "comments", Int.parameter], closure: articlesController.deleteComment ),
        
        // Favorites
        APICollection(method: .POST, paths: ["articles", String.parameter, "favorite"], closure: articlesController.postFavorite ),
        APICollection(method: .DELETE, paths: ["articles", String.parameter, "favorite"], closure: articlesController.deleteFavorite ),
        
        // Tags
        APICollection(method: .GET, paths: ["tags"], closure: tagsController.getTags ),
    ])
    
    // application launch
    try useCase.launch()
}

