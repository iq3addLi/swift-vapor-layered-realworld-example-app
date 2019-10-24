//
//  ConduitFluentRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure
import FluentMySQL
import CryptoSwift
import SwiftSlug

struct ConduitMySQLRepository: ConduitRepository{
    
    let database = MySQLDatabaseManager()
    
    func ifneededPreparetion() {
        print("preparetion")
    }
    
    // Sync
    
    // MARK: Users
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)>{

        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection -> EventLoopFuture<Users> in
                let salt = AES.randomIV(16).toHexString()
                let hash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(salt.utf8), keyLength: 32).calculate().toHexString()
                
                return database.insertUser(on: connection, name: username, email: email, hash: hash, salt: salt)
            }
            .map{ user -> (Int, User) in
                ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }
    
    func searchUser(email: String, password: String) throws -> ( userId: Int, user: User){
        guard let user = try database.selectUser(on: try database.newConnection(), email: email) else{
            throw Error( "User not found.")
        }

        let inputtedHash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(user.salt.utf8), keyLength: 32).calculate().toHexString()
        guard user.hash == inputtedHash else{
            throw Error( "password wrong.")
        }

        return ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
    }
    
    
    func searchUser(id: Int) throws -> User{
        guard let user = try database.selectUser(on: try database.newConnection(), id: id) else{
            throw Error( "User not found.") // Serious
        }
        return User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image)
    }
    
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) throws -> User{
        return try database.startTransaction{ connection in
             guard let user = try database.updateUser(on: connection, id: id, email: email, bio: bio, image: image) else{
                 throw Error( "User not found.") // Serious
             }
             return User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image)
        }
    }
    
    
    // MARK: Profiles
    func searchProfile(username: String, readingUserId: Int?) throws -> Profile{
        guard let profile = try database.selectProfile(on: try database.newConnection(), username: username, readIt: readingUserId) else{
            throw Error( "User not found.")
        }
        return profile
    }
    
    func follow(followee username: String, follower userId: Int) throws -> Profile{
        return try database.startTransaction{ connection in
             guard let profile = try database.insertFollow2(on: connection, followee: username, follower: userId) else{
                 throw Error( "Followee not found.")
             }
             return profile
        }
    }
    
    func unfollow(followee username: String, follower userId: Int) throws -> Profile{
        return try database.startTransaction{ connection in
             guard let profile = try database.deleteFollow(on: connection, followee: username, follower: userId) else{
                 throw Error( "Followee not found.")
             }
             return profile
        }
    }
    
    
    // MARK: Favorites
    func favorite(by userId: Int, for articleSlug: String) throws -> Article{
        return try database.startTransaction{ connection in
            guard let article = try database.insertFavorite(on: connection, by: userId, for: articleSlug) else{
                throw Error( "Favorited article is not found.")
            }
            return article
        }
    }
    
    func unfavorite(by userId: Int, for articleSlug: String) throws -> Article{
        return try database.startTransaction{ connection in
            guard let article = try database.deleteFavorite(on: connection, by: userId, for: articleSlug) else{
                throw Error( "No such article found.")
            }
            return article
        }
    }
    
    
    // MARK: Comments
    func comments(for articleSlug: String) throws -> [Comment]{
        return try database.selectComments(on: try database.newConnection(), for: articleSlug)
    }
    
    func addComment(for articleSlug: String, body: String, author userId: Int) throws -> Comment{
        return try database.startTransaction{ connection in
             return try database.insertComment(on: connection, for: articleSlug, body: body, author: userId)
        }
    }
    
    func deleteComment(for articleSlug: String, id: Int) throws{ // Slug is not required for MySQL implementation.
        return try database.startTransaction{ connection in
            return try database.deleteComments(on: connection, commentId: id)
        }
    }
    
    
    // MARK: Articles
    func articles( condition: ArticleCondition, readingUserId: Int? = nil, offset: Int? = nil, limit: Int? = nil ) throws -> [Article]{
        return try database.selectArticles(on: try database.newConnection(), condition: condition, readIt: readingUserId, offset: offset, limit: limit)
    }
    
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) throws -> Article {
        let slug = try title.convertedToSlug()
        return try database.startTransaction{ connection in
            guard let article = try database.insertArticle(on: connection, author: author, title: title, slug: slug, description: discription, body: body, tags: tagList) else{
                throw Error( "There was no problem with insertion, but there was no return value.")
            }
            return article
        }
    }
    
    func deleteArticle( slug: String ) throws{
        try database.startTransaction { connection -> Void in
            try database.deleteArticle(on: connection, slug: slug)
        }
    }
    
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) throws -> Article{
        try database.startTransaction { connection in
            try database.updateArticle(on: connection, slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
        }
    }
    
    // MARK: Tags
    func allTags() throws -> [String]{
        try database.selectTags(on: try database.newConnection())
    }
    
    
    // Async
    
    func authUser(email: String, password: String) -> Future<(Int, User)>{
        let database = self.database
        return database.futureConnection()
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
    
    func searchUser(id: Int) -> Future<(Int, User)>{
        let database = self.database
        return database.futureConnection()
            .flatMap{ connection in
                database.selectUser(on: try database.newConnection(), id: id)
            }
            .map{ userOrNil in
                guard let user = userOrNil else{
                    throw Error( "User not found.") // Serious
                }
                return ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }
    
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.updateUser(on: connection, id: id, email: email, bio: bio, image: image)
            }
            .map{ user in
                User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image)
            }
    }
    
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>{
        let database = self.database
        return database.futureConnection()
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
    
    func follow(followee username: String, follower userId: Int) -> Future<Profile>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.insertFollow(on: connection, followee: username, follower: userId)
            }
    }
    
    
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.deleteFollow(on: connection, followee: username, follower: userId)
            }
    }
    
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.insertFavorite(on: connection, by: userId, for: articleSlug)
            }
    }
    
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.deleteFavorite(on: connection, by: userId, for: articleSlug)
            }
    }
    
    func comments(for articleSlug: String) -> Future<[Comment]>{
        let database = self.database
        return database.futureConnection()
            .flatMap{ connection in
                database.selectComments(on: connection, for: articleSlug)
            }
    }
    
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.insertComment(on: connection, for: articleSlug, body: body, author: userId)
            }
        
    }

    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>{ // Slug is not required for MySQL implementation.
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.deleteComments(on: connection, commentId: id)
            }
    }
    
    func articles( condition: ArticleCondition, readingUserId: Int? = nil, offset: Int? = nil, limit: Int? = nil ) -> Future<[Article]>{
        let database = self.database
        return database.futureConnection()
            .flatMap{ connection in
                database.selectArticles(on: try database.newConnection(), condition: condition, readIt: readingUserId, offset: offset, limit: limit)
            }
    }
    
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article> {
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                let slug = try title.convertedToSlug()
                return database.insertArticle(on: connection, author: author, title: title, slug: slug, description: discription, body: body, tags: tagList)
            }
    }

    func deleteArticle( slug: String ) -> Future<Void> {
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.deleteArticle(on: connection, slug: slug)
            }
    }

    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>{
        let database = self.database
        return database.futureTransaction()
            .flatMap{ connection in
                database.updateArticle(on: connection, slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
            }
    }
    
    func allTags() -> Future<[String]>{
        let database = self.database
        return database.futureConnection()
            .flatMap{ connection in
                database.selectTags(on: connection)
            }
    }
}

