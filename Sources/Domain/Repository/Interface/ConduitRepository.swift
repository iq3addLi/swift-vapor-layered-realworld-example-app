//
//  ConduitRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Async


/// <#Description#>
protocol ConduitRepository{
    
    
    /// <#Description#>
    func ifneededPreparetion() throws
    
    // Async
    
    // Users
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    /// - returns:
    ///    <#Description#>
    func validate(username: String, email: String, password: String) throws -> Future<Void>
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    /// - returns:
    ///    <#Description#>
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)>
    
    
    /// <#Description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    /// - returns:
    ///    <#Description#>
    func authUser(email: String, password: String) -> Future<(Int, User)>
    
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - returns:
    ///    <#Description#>
    func searchUser(id: Int) -> Future<(Int, User)>
    
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Parameter email: <#email description#>
    /// - Parameter username: <#username description#>
    /// - Parameter bio: <#bio description#>
    /// - Parameter image: <#image description#>
    /// - returns:
    ///    <#Description#>
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User>
    
    // Profiles
    
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter readingUserId: <#readingUserId description#>
    /// - returns:
    ///    <#Description#>
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>
    
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    /// - returns:
    ///    <#Description#>
    func follow(followee username: String, follower userId: Int) -> Future<Profile>
    
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    /// - returns:
    ///    <#Description#>
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>
    
    // Favorites
    
    
    /// <#Description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - returns:
    ///    <#Description#>
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>
    
    
    /// <#Description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - returns:
    ///    <#Description#>
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>
    
    // Comments
    
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - returns:
    ///    <#Description#>
    func comments(for articleSlug: String) -> Future<[Comment]>
    
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter body: <#body description#>
    /// - Parameter userId: <#userId description#>
    /// - returns:
    ///    <#Description#>
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>
    
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter id: <#id description#>
    /// - returns:
    ///    <#Description#>
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>
    
    // Articles
    
    
    /// <#Description#>
    /// - Parameter condition: <#condition description#>
    /// - Parameter readingUserId: <#readingUserId description#>
    /// - Parameter offset: <#offset description#>
    /// - Parameter limit: <#limit description#>
    /// - returns:
    ///    <#Description#>
    func articles( condition: ArticleCondition, readingUserId: Int?, offset: Int?, limit: Int? ) -> Future<[Article]>
    
    
    /// <#Description#>
    /// - Parameter author: <#author description#>
    /// - Parameter title: <#title description#>
    /// - Parameter discription: <#discription description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    /// - returns:
    ///    <#Description#>
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article>
    
    
    /// <#Description#>
    /// - Parameter slug: <#slug description#>
    /// - returns:
    ///    <#Description#>
    func deleteArticle( slug: String ) -> Future<Void>
    
    
    /// <#Description#>
    /// - Parameter slug: <#slug description#>
    /// - Parameter title: <#title description#>
    /// - Parameter description: <#description description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    /// - Parameter userId: <#userId description#>
    /// - returns:
    ///    <#Description#>
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>
    
    // Tags
    
    
    /// <#Description#>
    /// - returns:
    ///    <#Description#>  
    func allTags() -> Future<[String]>
}
