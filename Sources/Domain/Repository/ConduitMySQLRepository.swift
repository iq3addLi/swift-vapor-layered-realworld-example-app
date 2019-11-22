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

        try database.connectionOnDatabaseEventLoop()
            .flatMap{ connection in
                Articles.create(on: connection)
                    .flatMap{ Comments.create(on: connection) }
                    .flatMap{ Favorites.create(on: connection) }
                    .flatMap{ Follows.create(on: connection) }
                    .flatMap{ Tags.create(on: connection) }
                    .flatMap{ Users.create(on: connection) }
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

        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection -> EventLoopFuture<Users> in
                let salt = AES.randomIV(16).toHexString()
                let hash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(salt.utf8), keyLength: 32).calculate().toHexString()
                
                return database.insertUser(on: connection, name: username, email: email, hash: hash, salt: salt)
            }
            .map{ user -> (Int, User) in
                ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }
    
    /// <#Description#>
    /// - Parameter email: <#email description#>
    /// - Parameter password: <#password description#>
    func authUser(email: String, password: String) -> Future<(Int, User)>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection -> Future<Users?> in
                database.selectUser(on: connection, email: email)
            }
            .map{ userOrNil -> Users in
                guard let user = userOrNil else{
                    throw Error( "User not found.")
                }
                let inputtedHash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(user.salt.utf8), keyLength: 32).calculate().toHexString()
                guard user.hash == inputtedHash else{
                    throw Error( "password wrong.")
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
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectUser(on: connection, id: id)
            }
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
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connectionOnTransaction in
                    database.updateUser(on: connectionOnTransaction, id: id, email: email, bio: bio, image: image)
                }
            }
            .map{ user in
                User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image)
            }
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter readingUserId: <#readingUserId description#>
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectProfile(on: connection, username: username, readIt: readingUserId)
            }
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
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.insertFollow(on: connection, followee: username, follower: userId)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.deleteFollow(on: connection, followee: username, follower: userId)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.insertFavorite(on: connection, by: userId, for: articleSlug)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.deleteFavorite(on: connection, by: userId, for: articleSlug)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func comments(for articleSlug: String) -> Future<[Comment]>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectComments(on: connection, for: articleSlug)
            }
    }
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter body: <#body description#>
    /// - Parameter userId: <#userId description#>
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.insertComment(on: connection, for: articleSlug, body: body, author: userId)
                }
            }
        
    }
    
    /// <#Description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter id: <#id description#>
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>{ // Slug is not required for MySQL implementation.
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.deleteComments(on: connection, commentId: id)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter condition: <#condition description#>
    /// - Parameter readingUserId: <#readingUserId description#>
    /// - Parameter offset: <#offset description#>
    /// - Parameter limit: <#limit description#>
    func articles( condition: ArticleCondition, readingUserId: Int? = nil, offset: Int? = nil, limit: Int? = nil ) -> Future<[Article]>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectArticles(on: connection, condition: condition, readIt: readingUserId, offset: offset, limit: limit)
            }
    }
    
    /// <#Description#>
    /// - Parameter author: <#author description#>
    /// - Parameter title: <#title description#>
    /// - Parameter discription: <#discription description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article> {
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                let slug = try title.convertedToSlug()
                return connection.transaction(on: .mysql) { conenction in
                    database.insertArticle(on: connection, author: author, title: title, slug: slug, description: discription, body: body, tags: tagList)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter slug: <#slug description#>
    func deleteArticle( slug: String ) -> Future<Void> {
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { conenction in
                    database.deleteArticle(on: connection, slug: slug)
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter slug: <#slug description#>
    /// - Parameter title: <#title description#>
    /// - Parameter description: <#description description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    /// - Parameter userId: <#userId description#>
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { conenction in
                    database.updateArticle(on: connection, slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
                }
            }
    }
    
    /// <#Description#>
    func allTags() -> Future<[String]>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectTags(on: connection)
            }
    }
}

