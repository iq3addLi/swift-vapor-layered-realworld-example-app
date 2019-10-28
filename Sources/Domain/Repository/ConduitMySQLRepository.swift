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
        // print("preparetion")
    }
    
    
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
    
    func follow(followee username: String, follower userId: Int) -> Future<Profile>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.insertFollow(on: connection, followee: username, follower: userId)
                }
            }
    }
    
    
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.deleteFollow(on: connection, followee: username, follower: userId)
                }
            }
    }
    
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.insertFavorite(on: connection, by: userId, for: articleSlug)
                }
            }
    }
    
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.deleteFavorite(on: connection, by: userId, for: articleSlug)
                }
            }
    }
    
    func comments(for articleSlug: String) -> Future<[Comment]>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectComments(on: connection, for: articleSlug)
            }
    }
    
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.insertComment(on: connection, for: articleSlug, body: body, author: userId)
                }
            }
        
    }

    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>{ // Slug is not required for MySQL implementation.
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { connection in
                    database.deleteComments(on: connection, commentId: id)
                }
            }
    }
    
    func articles( condition: ArticleCondition, readingUserId: Int? = nil, offset: Int? = nil, limit: Int? = nil ) -> Future<[Article]>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectArticles(on: connection, condition: condition, readIt: readingUserId, offset: offset, limit: limit)
            }
    }
    
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

    func deleteArticle( slug: String ) -> Future<Void> {
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { conenction in
                    database.deleteArticle(on: connection, slug: slug)
                }
            }
    }

    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                connection.transaction(on: .mysql) { conenction in
                    database.updateArticle(on: connection, slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
                }
            }
    }
    
    func allTags() -> Future<[String]>{
        let database = self.database
        return database.connectionOnCurrentEventLoop()
            .flatMap{ connection in
                database.selectTags(on: connection)
            }
    }
}

