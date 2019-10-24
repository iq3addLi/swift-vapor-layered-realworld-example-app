//
//  ConduitRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Async

protocol ConduitRepository{
    
    func ifneededPreparetion()    
    
    // Async
    
    // Users
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)>
    func authUser(email: String, password: String) -> Future<(Int, User)>
    func searchUser(id: Int) -> Future<(Int, User)>
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User>
    
    // Profiles
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>
    func follow(followee username: String, follower userId: Int) -> Future<Profile>
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>
    
    // Favorites
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>
    
    // Comments
    func comments(for articleSlug: String) -> Future<[Comment]>
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>
    
    // Articles
    func articles( condition: ArticleCondition, readingUserId: Int?, offset: Int?, limit: Int? ) -> Future<[Article]>
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article>
    func deleteArticle( slug: String ) -> Future<Void>
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>
    
    // Tags
    func allTags() -> Future<[String]>
}
