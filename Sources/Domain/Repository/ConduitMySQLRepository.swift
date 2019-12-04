//
//  ConduitFluentRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure
import CryptoSwift
import SwiftSlug
import NIO

/// ConduitRepository implemented in MySQL.
///
/// ### Extras
/// An instance is created for each UseCase, which is obviously useless. It's a good idea to make it a singleton, but it is left as it is because the property has no side effects.
struct ConduitMySQLRepository: ConduitRepository {

    // MARK: Properties
    
    /// Use this to instruct the database.
    let database = MySQLDatabaseManager.default

    // MARK: Preparetion
    
    /// Create a table in the DB.
    func ifneededPreparetion() throws {
        try database.instantCommunication { connection in
             Articles.create(on: connection)
                .flatMap { Comments.create(on: connection) }
                .flatMap { Favorites.create(on: connection) }
                .flatMap { Follows.create(on: connection) }
                .flatMap { Tags.create(on: connection) }
                .flatMap { Users.create(on: connection) }
            }.wait()
    }
    
    // MARK: Validation
    
    /// Use Vapor validation.
    ///
    /// ### Extras
    /// There was also a way to prepare a Varidation Repository.
    /// - Parameters:
    ///   - username: Username to be verified.
    ///   - email: Email to be verified.
    ///   - password: Password to be verified.
    func validate(username: String, email: String, password: String) throws -> Future<Void> {
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

    // MARK: Query for Database
    
    /// Implementation of user registration using MySQL.
    /// - Parameter username: A username.
    /// - Parameter email: A email.
    /// - Parameter password: A password.
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)> {

        guard let currentEventLoop = MultiThreadedEventLoopGroup.currentEventLoop else {
            fatalError("The currentEventLoop is not found. There may be a bug.")
        }
        return currentEventLoop.submit { () -> (String, String) in
                let salt = AES.randomIV(16).toHexString()
                let hash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(salt.utf8), keyLength: 32).calculate().toHexString() // Note: Too late for debug, but not for release.
                return (salt, hash)
            }
            .flatMap { saltWithHash in
                self.database.insertUser(name: username, email: email, hash: saltWithHash.1, salt: saltWithHash.0)
            }
            .map { user -> (Int, User) in
                ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }

    
    /// Implementation of user authentication using MySQL.
    /// - Parameters:
    ///   - email: A email.
    ///   - password: A password.
    func authUser(email: String, password: String) -> Future<(Int, User)> {
        database.selectUser(email: email)
            .map { userOrNil -> Users in
                guard let user = userOrNil else {
                    throw Error( "User not found.", status: 404)
                }
                let inputtedHash = try PKCS5.PBKDF2(password: Array(password.utf8), salt: Array(user.salt.utf8), keyLength: 32).calculate().toHexString()
                guard user.hash == inputtedHash else {
                    throw ValidationError(errors: ["email or password": ["is invalid"]])
                }
                return user
            }
            .map { user -> (Int, User) in
                ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }

    /// Implementation of user search using MySQL.
    /// - Parameter id: `User`s Id
    func searchUser(id: Int) -> Future<(Int, User)> {
        database.selectUser(id: id)
            .map { userOrNil in
                guard let user = userOrNil else {
                    throw Error( "User not found.", status: 404) // Serious
                }
                return ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image) )
            }
    }

    /// Implementation of update user's infomation using MySQL.
    /// - Parameters:
    ///   - id: User's id
    ///   - email: A email
    ///   - username: A username
    ///   - bio: A bio
    ///   - image: An image URL
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User> {
        database.updateUser(id: id, email: email, bio: bio, image: image)
            .map { user in
                User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image)
            }
    }

    /// Implementation of search profile using MySQL.
    /// - Parameters:
    ///   - username: A username
    ///   - readingUserId: User's Id that referenced Profile
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile> {
        database.selectProfile(username: username, readIt: readingUserId)
            .map { profileOrNil in
                guard let profile = profileOrNil else {
                    throw Error( "User not found.", status: 404)
                }
                return profile
            }
    }

    /// Implementation of user follow using MySQL.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - userId: <#userId description#>
    func follow(followee username: String, follower userId: Int) -> Future<Profile> {
        database.insertFollow(followee: username, follower: userId)
    }

    /// Implementation of user unfollow using MySQL.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - userId: <#userId description#>
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile> {
        database.deleteFollow(followee: username, follower: userId)
    }

    /// Implementation of favorite to article using MySQL.
    /// - Parameters:
    ///   - userId: <#userId description#>
    ///   - articleSlug: <#articleSlug description#>
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        database.insertFavorite(by: userId, for: articleSlug)
    }

    /// Implementation of unfavorite to article using MySQL.
    /// - Parameters:
    ///   - userId: <#userId description#>
    ///   - articleSlug: <#articleSlug description#>
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        database.deleteFavorite(by: userId, for: articleSlug)
    }

    /// Implementation of get comments of article using MySQL.
    /// - Parameter articleSlug: <#articleSlug description#>
    func comments(for articleSlug: String) -> Future<[Comment]> {
        database.selectComments(for: articleSlug)
    }

    /// Implementation of comment to article using MySQL.
    /// - Parameters:
    ///   - articleSlug: <#articleSlug description#>
    ///   - body: <#body description#>
    ///   - userId: <#userId description#>
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        database.insertComment(for: articleSlug, body: body, author: userId)
    }

    /// Implementation of uncomment to article using MySQL.
    /// - Parameters:
    ///   - articleSlug: <#articleSlug description#>
    ///   - id: <#id description#>
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void> { // Slug is not required for MySQL implementation.
        database.deleteComments(commentId: id)
    }
    
    /// Implementation of get articles using MySQL.
    /// - Parameters:
    ///   - condition: <#condition description#>
    ///   - readingUserId: <#readingUserId description#>
    ///   - offset: <#offset description#>
    ///   - limit: <#limit description#>
    func articles( condition: ArticleCondition, readingUserId: Int? = nil, offset: Int? = nil, limit: Int? = nil ) -> Future<[Article]> {
        database.selectArticles(condition: condition, readIt: readingUserId, offset: offset, limit: limit)
    }

    /// Implementation of add article using MySQL.
    /// - Parameters:
    ///   - author: <#author description#>
    ///   - title: <#title description#>
    ///   - discription: <#discription description#>
    ///   - body: <#body description#>
    ///   - tagList: <#tagList description#>
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article> {
        guard let currentEventLoop = MultiThreadedEventLoopGroup.currentEventLoop else {
            fatalError("The currentEventLoop is not found. There may be a bug.")
        }
        return currentEventLoop
            .submit { () -> String in
                try title.convertedToSlug() + "-" + .random(length: 8)
            }
            .flatMap { slug in
                self.database.insertArticle(author: author, title: title, slug: slug, description: discription, body: body, tags: { tagList in
                    // Trim whitespace, camecased and remove duplicate element
                    Array( Set(tagList.map { $0.camelcased }))
                }(tagList))
            }
    }

    /// Implementation of delete article using MySQL.
    /// - Parameter slug: <#slug description#>
    func deleteArticle( slug: String ) -> Future<Void> {
        database.deleteArticle(slug: slug)
    }

    /// Implementation of update article using MySQL.
    /// - Parameters:
    ///   - slug: <#slug description#>
    ///   - title: <#title description#>
    ///   - description: <#description description#>
    ///   - body: <#body description#>
    ///   - tagList: <#tagList description#>
    ///   - userId: <#userId description#>
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article> {
        database.updateArticle(slug: slug, title: title, description: description, body: body, tagList: tagList != nil ? { tagList in
            // Trim whitespace, camecased and remove duplicate element
            Array( Set(tagList.map { $0.camelcased }))
        }(tagList!) : nil, readIt: userId)
    }

    /// Implementation of get tags using MySQL.
    func allTags() -> Future<[String]> {
        database.selectTags()
    }
}
