//
//  ConduitRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure

public protocol ConduitRepository{
    
    func ifneededPreparetion()
    
    // Users
    func registerUser(name username: String, email: String, password: String) throws -> ( userId: Int, user: User)
    
    func searchUser(email: String, password: String) throws -> ( userId: Int, user: User)
    
    func searchUser(id: Int) throws -> User
    
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) throws -> User
    
    // Profiles
    func searchProfile(username: String, readingUserId: Int?) throws -> Profile
    
    func follow(followee username: String, follower userId: Int) throws -> Profile
    
    func unfollow(followee username: String, follower userId: Int) throws -> Profile
    
    // Favorites
    func favorite(by userId: Int, for articleSlug: String) throws -> Article
    
    func unfavorite(by userId: Int, for articleSlug: String) throws -> Article
    
    // Comments
    func comments(for articleSlug: String) throws -> [Comment]
    
    func addComment(for articleSlug: String, body: String, author: Int) throws -> Comment
    
    func deleteComment(for articleSlug: String, id: Int) throws
    
    
    // Articles
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) throws -> Article
    
    func articles( condition: ArticleCondition, readingUserId: Int?, offset: Int?, limit: Int? ) throws -> [Article]
    
    func deleteArticle( slug: String ) throws
    
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) throws -> Article
    
    // Tags
    func allTags() throws -> [String]
}
