//
//  MySQLDatabaseManager+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//

import Infrastructure

import Foundation
import SQLKit
import MySQLNIO
import FluentMySQLDriver


// MARK: Functions In Domain

/// Extensions required by Domain.
extension MySQLDatabaseManager {

    /// Standard global instance of this class.
    public static var environmental: Self {
        guard
            let hostname = ProcessInfo.processInfo.environment["MYSQL_HOSTNAME"],
            let username = ProcessInfo.processInfo.environment["MYSQL_USERNAME"],
            let password = ProcessInfo.processInfo.environment["MYSQL_PASSWORD"],
            let database = ProcessInfo.processInfo.environment["MYSQL_DATABASE"]
        else {
            fatalError("""
            The environment variable for MySQL must be set to start the application.
            "MYSQL_HOSTNAME", "MYSQL_USERNAME", "MYSQL_PASSWORD" and "MYSQL_DATABASE".
            """)
        }
        return Self(
            hostname: hostname,
            username: username,
            password: password,
            database: database
        )
    }
    
    /// Returns the result of querying MySQL Database for Users.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter email: A email address. Information to identify the user.
    /// - returns:
    ///    The `Future` that returns `Users` or nil. Nil is when not found user.
    func selectUser(email: String) -> Future<Users?> {
        Users
            .query(on: fluent)
            .filter(\.$email == email)
            .all()
            .map { $0.first }
    }
    
    /// Returns the result of querying MySQL Database for Users.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter id: A user id. Information to identify the user.
    /// - returns:
    ///    The `Future` that returns `Users` or nil. Nil is when not found user.
    func selectUser(id: Int) -> Future<Users?> {
        Users
            .query(on: fluent)
            .filter(\.$id == id)
            .all()
            .map { $0.first }
    }
    
    /// Returns the result of querying MySQL Database for Users.
    /// - Parameters:
    ///   - connection: A valid connection to MySQL.
    ///   - username: A user name. Information to identify the user.
    /// - returns:
    ///    The `Future` that returns `Users` or nil. Nil is when not found user.
    func selectUser(username: String) -> Future<Users?> {
        Users
            .query(on: fluent)
            .filter(\.$username == username)
            .all()
            .map { $0.first }
    }
    
    /// Insert Users into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter username: New user name to register.
    /// - Parameter email: New user email to register.
    /// - Parameter hash: Hashed password.
    /// - Parameter salt: Salt used when hashing.
    /// - returns:
    ///    The `Future` that returns `Users`.
    func insertUser(name username: String, email: String, hash: String, salt: String) -> Future<Users> {
        let users = Users(id: nil, username: username, email: email, hash: hash, salt: salt)
        return users.save(on: fluent)
                    .map { users }
    }

    /// Update Users into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter id: ID of User to be updated.
    /// - Parameter email: New email. No update if nil.
    /// - Parameter bio: New bio. No update if nil.
    /// - Parameter image: New image. No update if nil.
    /// - returns:
    ///    The `Future` that returns `Users`.
    func updateUser(id: Int, email: String?, bio: String?, image: String?) -> Future<Users> {
        fluent.transaction { fluent in
            Users
                .query(on: fluent)
                .filter(\.$id == id)
                .first()
                .flatMapThrowing { users -> Users in
                    guard let user = users else {
                        throw Error("Update process is failed. User not found.")
                    }
                    return user
                }
                .flatMap { [weak self] user in
                    email.map{ user.email = $0 }
                    bio.map{ user.bio = $0 }
                    image.map{ user.image = $0 }
                    return user.update(on: self!.fluent )
                                .map{ user }
                }
        }
    }
    
    
    /// Query MySQL Database for Profile.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter username: A user name. Information to identify the user.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    `Future` which return `Profile` of a user as seen by this user.
    func selectProfile(username: String, readIt userId: Int? = nil) -> Future<Profile?> {
        sql
            .raw( SQLQueryString( RawSQLQueries.selectUser(name: username, follower: userId)) )
            .all(decoding: UserWithFollowRow.self )
            .map { rows in
                guard let row = rows.first else {
                    return nil
                }
                return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
            }
    }


    /// Insert follow into MySQL Database。.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter username: A user name of followee.
    /// - Parameter userId: A user id of follower.
    /// - returns:
    ///   `Future` which return `Profile` of followee as seen by follower.
    func insertFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        var followee: Users?
        // var follow: Follows?
        return fluent.transaction { fluent in
            Users
                .query(on: fluent)
                .filter(\.$username == username)
                .all()
                .flatMapThrowing { users -> Follows in
                    guard let user = users.first else {
                        throw Error("Insert process is failed. Followee is not found.")
                    }
                    followee = user
                    return Follows(id: nil, followee: user.id!, follower: userId)
                }.flatMap { aFollow -> Future<Void> in
                    // follow = aFollow
                    return aFollow.save(on: fluent)
                }
        }.map { _ in
            Profile(username: followee!.username, bio: followee!.bio, image: followee!.image, following: true /*follow!.$follower.id == userId // simplified */ )
        }
    }

    
    /// Delete follow into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter username: A user name of followee.
    /// - Parameter userId: A user id of follower.
    /// - warnings:
    ///  In MySQL implementation, no error occurs even if User does not exist. It is possible to confirm that User exists in advance.
    /// - returns:
    ///   `Future` which return `Profile` of followee as seen by follower.
    func deleteFollow( followee username: String, follower userId: Int ) -> Future<Profile> {
        fluent.transaction { fluent in
            (fluent as! MySQLDatabase)
                .query( RawSQLQueries.deleteFollows(followee: username, follower: userId ))
                .flatMap{ _ in
                    (fluent as! SQLDatabase)
                    .raw(SQLQueryString( RawSQLQueries.selectUser(name: username, follower: userId) ))
                    .all(decoding: UserWithFollowRow.self )
                }
                .flatMapThrowing { rows -> Profile in
                    guard let user = rows.first else {
                        throw Error("Delete process is failed. Followee is not found. Logically impossible.", status: 500)
                    }
                    return Profile(username: user.username, bio: user.bio, image: user.image, following: user.following ?? false)
                }
        }
    }
    
    /// Insert favorite into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter userId: A favorite userId.
    /// - Parameter articleSlug: A slug of favorite article.
    /// - returns:
    ///    The `Future` which Returning favorite `Articles`.
    func insertFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        fluent.transaction { fluent in
            (fluent as! MySQLDatabase)
                .query( RawSQLQueries.insertFavorites(for: articleSlug, by: userId ) )
                .flatMap { _ in
                    (fluent as! SQLDatabase)
                        .raw( SQLQueryString(RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId)) )
                        .all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
                }.flatMapThrowing { rows -> Article in
                    guard let row = rows.first else {
                        throw Error("Insert process is failed. Article is not found. Logically impossible.", status: 500)
                    }
                    return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
                    )
                }
        }
    }
    
    
    /// Delete favorite into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter userId: Id of the user to remove favorite.
    /// - Parameter articleSlug: Slug of article to remove favorite.
    /// - returns:
    ///   The `Future` which returning `Articles` which stopped favoriting.
    func deleteFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        
        fluent.transaction { fluent in
            (fluent as! SQLDatabase)
                .raw( SQLQueryString( RawSQLQueries.deleteFavorites(for: articleSlug, by: userId )) )
                .all()
                .flatMap { _ in
                    (fluent as! SQLDatabase)
                        .raw( SQLQueryString( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId)) )
                        .all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
                }
                .flatMapThrowing { rows in
                    guard let row = rows.first else {
                        throw Error("Delete process is failed. Article is not found. Logically impossible.", status: 500)
                    }
                    return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
                }
        }
    }

    /// Queries MySQL Database for Comments on Articles.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter articleSlug: Slug of the commented article.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    The `Future` that returns `[Comment]`.
    func selectComments(for articleSlug: String, readit userId: Int? = nil) -> Future<[Comment]> {
        sql
            .raw( SQLQueryString( RawSQLQueries.selectComments(for: articleSlug, readIt: userId)) )
            .all(decoding: CommentWithAuthorRow.self)
            .map { rows in
                rows.map { comment in
                Comment(_id: comment.id, createdAt: comment.createdAt, updatedAt: comment.updatedAt, body: comment.body, author: Profile(username: comment.username, bio: comment.bio, image: comment.image, following: comment.following ?? false))
                }
            }
    }

    
    /// Insert Comments to Articles in MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter articleSlug: Slug of the article to comment.
    /// - Parameter body: Body of comment.
    /// - Parameter userId: Id of comment author.
    /// - returns:
    ///    The `Future` that returns `Comment`.
    func insertComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        fluent.transaction{ fluent -> Future<Comments> in
            Articles
                .query(on: fluent)
                .filter( \.$slug == articleSlug )
                .all()
                .flatMapThrowing { articles in
                    guard let article = articles.first else {
                        throw Error( "No article to comment was found")
                    }
                    return Comments(body: body, author: userId, article: article.id! )
                }
                .flatMap { (comments: Comments) in
                    comments.save(on: fluent).flatMap{ _ -> Future<[Comments]> in
                        Comments.query(on: fluent)
                            .filter(\.$id == comments.id!)
                            .all()
                    }
                }
                .flatMapThrowing { comments -> Comments in
                    guard let comment = comments.first else {
                        throw Error( "The comment was saved successfully, but fluent did not return a value. Done rollback.", status: 500)
                    }
                    return comment
                }
        }.flatMap { [weak self] comment in
            comment.$author.load(on: self!.fluent).map{ comment }
        }.map { comment in
            Comment(_id: comment.id!,
                    createdAt: comment.createdAt!,
                    updatedAt: comment.updatedAt!,
                    body: comment.body,
                    author: Profile(
                        username: comment.author.username,
                        bio: comment.author.bio,
                        image: comment.author.image,
                        following: false /* Because It's own. */
                )
            )
        }
    }
    /// Delete Comments in MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter commentId: ID of comment to remove.
    /// - returns:
    ///    The `Future` that returns `Void`.
    func deleteComments(commentId: Int ) -> Future<Void> {
        fluent.transaction { fluent in
            (fluent as! SQLDatabase)
            .raw( SQLQueryString(RawSQLQueries.deleteComments( id: commentId )) )
            .all()
            .map { _ in return }
        }
    }
    
    
    /// Query MySQL Database for Articles.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter condition: Condition used to search for articles.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - Parameter offset: Offset to search results. nil means unspecified.
    /// - Parameter limit: Limit to search results. nil means unspecified.
    /// - returns:
    ///    The `Future` that returns `[Article]`.
    func selectArticles( condition: ArticleCondition, readIt userId: Int? = nil, offset: Int? = nil, limit: Int? = nil) -> Future<[Article]> {
        sql
            .raw( SQLQueryString( RawSQLQueries.selectArticles(condition: condition, readIt: userId, offset: offset, limit: limit) ) )
            .all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
            .map { rows in
                rows.map { row in
                    Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
                }
            }
    }

    /// Insert Articles into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter author: Id of the new article author.
    /// - Parameter title: Title of the new article.
    /// - Parameter slug: Slug of the new article.
    /// - Parameter description: Description of the new article.
    /// - Parameter body: Body of the new article.
    /// - Parameter tags: Array of tag strings attached to new article.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    The `Future` that returns `Article`.
    func insertArticle( author: Int, title: String, slug: String, description: String, body: String, tags: [String], readIt userId: Int? = nil) -> Future<Article> {
        
        fluent.transaction { fluent -> Future<Void> in
            let article = Articles(id: nil, slug: slug, title: title, description: description, body: body, author: author)
            return article
                .save(on: fluent)
                .flatMap { _ -> Future<Void> in
                    let insertTags = tags.map {
                        Tags(id: nil, article: article.id!, tag: $0 )
                            .save(on: fluent)
                            .map { _ in return }
                    }
                    switch insertTags.serializedFuture() {
                    case .some(let futures): return futures
                    case .none: return fluent.eventLoop.makeSucceededFuture(Void())
                    }
                }
        }
        .flatMap { [weak self] _ in
            self!.selectArticles(condition: .slug(slug) )
        }
        .flatMapThrowing { articles in
            guard let article = articles.first else {
                throw Error( "The article was saved successfully, but fluent did not return a value.", status: 500)
            }
            return article
        }
    }

    /// Update Articles into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter slug: Slug of article to be updated.
    /// - Parameter title: Title of article to be updated, nil means unspecified.
    /// - Parameter description: Description of article to be updated, nil means unspecified.
    /// - Parameter body: Body of article to be updated, nil means unspecified.
    /// - Parameter tagList: Array of tag strings attached to be updated article, nil means unspecified.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    The `Future` that returns `Article`.
    func updateArticle(slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article> {
        
        // Define update article process
        let updateArticles = { fluent in
            Articles
                .query(on: fluent)
                .filter(\.$slug == slug)
                .all()
                .flatMapThrowing { rows -> Articles in
                    guard let row = rows.first else {
                        throw Error( "Update process is failed. Article is not found. Logically impossible.", status: 500)
                    }
                    return row
                }
                .flatMap { article -> EventLoopFuture<Articles> in
                    title.map { article.title = $0 }
                    description.map { article.description = $0 }
                    body.map { article.body = $0 }

                    return article
                        .update(on: fluent)
                        .map{ article }
                }
        }
        
        // Define finishing process
        let getArticles: () -> Future<[Article]> = { [weak self] in
            self!.selectArticles(condition: .slug(slug), readIt: userId)
        }
        let pickArticle: ([Article]) throws -> Article = { articles in
            guard let article = articles.first else {
                throw Error("Update process is successed. But article is not found. Logically impossible.", status: 500)
            }
            return article
        }
        
        // case of no tags updating
        guard let tagStrings = tagList else {
            return fluent.transaction( updateArticles )
                .map{ _ in return }
                .flatMap( getArticles )
                .flatMapThrowing( pickArticle )
        }

        // case of has tags updating
        return fluent.transaction{ fluent in
            
                var article: Articles?
                return updateArticles( fluent )
                .flatMap { a -> EventLoopFuture<Void> in
                    article = a
                    return a.$tags.load(on: fluent)
                }
                .flatMap { _ -> EventLoopFuture<Void> in
                    let tags = article!.tags
                    let deletings = tags
                                        .filter { tagStrings.contains($0.tag) == false }
                                        .map { $0.delete(on: fluent) }
                    let insertings = tagStrings
                                        .filter { tags.map { $0.tag }.contains($0) == false }
                                        .map { Tags(id: nil, article: article!.id!, tag: $0).save(on: fluent) }
                    return (deletings + insertings).serializedFuture() ?? fluent.eventLoop.makeSucceededFuture(Void())
                }
            }
            .flatMap( getArticles )
            .flatMapThrowing( pickArticle )
    }
    
    /// Delete Articles in MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter slug: Slug of article to be deleted.
    /// - returns:
    ///    The `Future` that returns `Void`.
    func deleteArticle(slug: String ) -> Future<Void> {
        fluent.transaction { database in
            (database as! SQLDatabase)
                .raw( SQLQueryString( RawSQLQueries.deleteArticles(slug: slug)) )
                .all()
                .map { _ in return }
        }
    }
    /// Query MySQL Database for all tags.
    /// - Parameter connection: A valid connection to MySQL.
    /// - returns:
    ///    The `Future` that returns array of tag as `[String]`.
    func selectTags() -> Future<[String]> {
        sql
            .raw( SQLQueryString(RawSQLQueries.selectTags()) )
            .all(decoding: TagOnlyRow.self )
            .map { rows in rows.map { $0.tag } }
    }
}
