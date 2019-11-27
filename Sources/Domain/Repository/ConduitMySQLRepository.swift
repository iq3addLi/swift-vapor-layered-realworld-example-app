//
//  ConduitFluentRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure
import CryptoSwift
import SwiftSlug
import Async
import FluentMySQL


/// <#Description#>
struct ConduitMySQLRepository: ConduitRepository{
    
    let database = MySQLDatabaseManager.default
    
    /// <#Description#>
    func ifneededPreparetion() throws{

        var connection: MySQLConnection?
        return try database.requestConnectionOnInstantEventLoop()
            .flatMap{ conn in
                connection = conn
                return Articles.create(on: conn)
                    .flatMap{ Comments.create(on: conn) }
                    .flatMap{ Favorites.create(on: conn) }
                    .flatMap{ Follows.create(on: conn) }
                    .flatMap{ Tags.create(on: conn) }
                    .flatMap{ Users.create(on: conn) }
            }
            .always {
                self.database.correctInstantEventLoop(connection: connection!)
            }
            .wait()
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    func validate(username: String, email: String, password: String) throws -> Future<Void>{
        let validation = Validation()
        return validation.reduce([
            validation.blank(key: "username", value: username),
            validation.count(1..., key: "username", value: username),
            validation.count(...20, key: "username", value: username),
            database.isUnique(username: username),
            validation.blank(key: "email", value: email),
            validation.email(email),
            database.isUnique(email: email),
            validation.blank(key: "password", value: password),
            validation.count(8..., key: "password", value: password)
        ]).map { issues in
            if issues.count > 0 {
                throw issues.generateError()
            }
        }
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)>{

        guard let currentEventLoop = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("The currentEventLoop is not found. There may be a bug.")
        }
        return currentEventLoop.submit { () -> (String, String) in
                let salt = AES.randomIV(16).toHexString()
                let hash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(salt.utf8), keyLength: 32).calculate().toHexString()
                return (salt, hash)
            }
            .flatMap{ saltWithHash in
                self.database.insertUser(name: username, email: email, hash: saltWithHash.1, salt: saltWithHash.0)
            }
            .map{ user -> (Int, User) in
                ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }
    
    /// <#Description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    func authUser(email: String, password: String) -> Future<(Int, User)>{
        database.selectUser(email: email)
            .map{ userOrNil -> Users in
                guard let user = userOrNil else{
                    throw Error( "User not found.")
                }
                let inputtedHash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(user.salt.utf8), keyLength: 32).calculate().toHexString()
                guard user.hash == inputtedHash else{
                    throw Error( "Password is wrong.")
                }
                return user
            }
            .map{ user -> (Int, User) in
                ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    func searchUser(id: Int) -> Future<(Int, User)>{
        database.selectUser(id: id)
            .map{ userOrNil in
                guard let user = userOrNil else{
                    throw Error( "User not found.") // Serious
                }
                return ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Parameter email: <#email description#>
    /// - Parameter username: <#username description#>
    /// - Parameter bio: <#bio description#>
    /// - Parameter image: <#image description#>
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User>{
        database.updateUser(id: id, email: email, bio: bio, image: image)
            .map{ user in
                User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image)
            }
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter readingUserId: <#readingUserId description#>
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>{
        database.selectProfile(username: username, readIt: readingUserId)
            .map{ profileOrNil in
                guard let profile = profileOrNil else{
                    throw Error( "User not found.")
                }
                return profile
            }
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func follow(followee username: String, follower userId: Int) -> Future<Profile>{
        database.insertFollow(followee: username, follower: userId)
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>{
        database.deleteFollow(followee: username, follower: userId)
    }
    
    /// <#Description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        database.insertFavorite(by: userId, for: articleSlug)
    }
    
    /// <#Description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        database.deleteFavorite(by: userId, for: articleSlug)
    }
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func comments(for articleSlug: String) -> Future<[Comment]>{
        database.selectComments(for: articleSlug)
    }
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter body: <#body description#>
    /// - Parameter userId: <#userId description#>
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>{
        database.insertComment(for: articleSlug, body: body, author: userId)
    }
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter id: <#id description#>
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>{ // Slug is not required for MySQL implementation.
        database.deleteComments(commentId: id)
    }
    
    /// <#Description#>
    /// - Parameter condition: <#condition description#>
    /// - Parameter readingUserId: <#readingUserId description#>
    /// - Parameter offset: <#offset description#>
    /// - Parameter limit: <#limit description#>
    func articles( condition: ArticleCondition, readingUserId: Int? = nil, offset: Int? = nil, limit: Int? = nil ) -> Future<[Article]>{
        database.selectArticles(condition: condition, readIt: readingUserId, offset: offset, limit: limit)
    }
    
    /// <#Description#>
    /// - Parameter author: <#author description#>
    /// - Parameter title: <#title description#>
    /// - Parameter discription: <#discription description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article> {
        guard let currentEventLoop = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("The currentEventLoop is not found. There may be a bug.")
        }
        return currentEventLoop
            .submit{ () -> String in
                try title.convertedToSlug()
            }
            .flatMap{ slug in
                self.database.insertArticle(author: author, title: title, slug: slug, description: discription, body: body, tags: tagList)
            }
    }
    
    /// <#Description#>
    /// - Parameter slug: <#slug description#>
    func deleteArticle( slug: String ) -> Future<Void> {
        database.deleteArticle(slug: slug)
    }
    
    /// <#Description#>
    /// - Parameter slug: <#slug description#>
    /// - Parameter title: <#title description#>
    /// - Parameter description: <#description description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    /// - Parameter userId: <#userId description#>
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>{
        database.updateArticle(slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
    }
    
    /// <#Description#>
    func allTags() -> Future<[String]>{
        database.selectTags()
    }
}

