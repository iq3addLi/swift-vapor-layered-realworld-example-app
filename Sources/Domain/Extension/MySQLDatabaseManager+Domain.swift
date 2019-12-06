//
//  MySQLDatabaseManager+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//

import Infrastructure
import FluentMySQL

// MARK: Functions In Domain

/// Extensions required by Domain.
extension MySQLDatabaseManager {

    /// Returns the result of querying MySQL Database for Users.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter email: A email address. Information to identify the user.
    /// - returns:
    ///    <#Description#>
    func selectUser(on connection: MySQLConnection, email: String) -> Future<Users?> {
        Users
            .query(on: connection)
            .filter(\Users.email == email)
            .all()
            .map { $0.first }
    }

    /// Returns the result of querying MySQL Database for Users.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter id: A user id. Information to identify the user.
    /// - returns:
    ///    <#Description#>
    func selectUser(on connection: MySQLConnection, id: Int) -> Future<Users?> {
        Users
            .query(on: connection)
            .filter(\Users.id == id)
            .all()
            .map { $0.first }
    }
    
    /// Returns the result of querying MySQL Database for Users.
    /// - Parameters:
    ///   - connection: A valid connection to MySQL.
    ///   - username: A user name. Information to identify the user.
    /// - returns:
    ///    <#Description#>
    func selectUser(on connection: MySQLConnection, username: String) -> Future<Users?> {
        Users
            .query(on: connection)
            .filter(\Users.username == username)
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
    ///    <#Description#>
    func insertUser(on connection: MySQLConnection, name username: String, email: String, hash: String, salt: String) -> Future<Users> {
        Users(id: nil, username: username, email: email, hash: hash, salt: salt)
            .save(on: connection)
    }

    /// Update Users into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter id: ID of User to be updated.
    /// - Parameter email: New email. No update if nil.
    /// - Parameter bio: New bio. No update if nil.
    /// - Parameter image: New image. No update if nil.
    /// - returns:
    ///    <#Description#>
    func updateUser(on connection: MySQLConnection, id: Int, email: String?, bio: String?, image: String?) -> Future<Users> {
        Users
            .query(on: connection)
            .filter(\Users.id == id)
            .first()
            .map { users -> Users in
                guard let user = users else {
                    throw Error("Update process is failed. User not found.", status: 404)
                }
                return user
            }
            .flatMap { user in
                if let email = email { user.email = email }
                if let bio = bio { user.bio = bio }
                if let image = image { user.image = image }
                return user.update(on: connection )
            }
    }

    /// Query MySQL Database for Profile.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter username: A user name. Information to identify the user.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    <#Description#>
    func selectProfile(on connection: MySQLConnection, username: String, readIt userId: Int? = nil) -> Future<Profile?> {
        connection
            .raw( RawSQLQueries.selectUser(name: username, follower: userId) )
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
    ///    <#Description#>
    func insertFollow(on connection: MySQLConnection, followee username: String, follower userId: Int ) -> Future<Profile> {
        var followee: Users?
        return Users
            .query(on: connection)
            .filter(\Users.username == username)
            .all()
            .flatMap { rows -> Future<Follows> in
                guard let row = rows.first else {
                    throw Error("Insert process is failed. Followee is not found.", status: 404)
                }
                followee = row
                return Follows(id: nil, followee: row.id!, follower: userId).save(on: connection)
            }
            .map { follow in
                Profile(username: followee!.username, bio: followee!.bio, image: followee!.image, following: follow.followee == followee!.id )
            }
    }

    /// Delete follow into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter username: A user name of followee.
    /// - Parameter userId: A user id of follower.
    /// - warnings:
    ///  In MySQL implementation, no error occurs even if User does not exist. It is possible to confirm that User exists in advance.
    /// - returns:
    ///    <#Description#>
    func deleteFollow(on connection: MySQLConnection, followee username: String, follower userId: Int ) -> Future<Profile> {
        connection
            .raw( RawSQLQueries.deleteFollows(followee: username, follower: userId) )
            .all()
            .flatMap { _ in
                connection.raw( RawSQLQueries.selectUser(name: username, follower: userId) ).all(decoding: UserWithFollowRow.self)
            }
            .map { rows in
                guard let user = rows.first else {
                    throw Error("Delete process is failed. Followee is not found. Logically impossible.", status: 500)
                }
                return Profile(username: user.username, bio: user.bio, image: user.image, following: user.following ?? false)
            }
    }

    /// Insert favorite into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter userId: A favorite userId.
    /// - Parameter articleSlug: A slug of favorite article.
    /// - returns:
    ///    <#Description#>
    func insertFavorite(on connection: MySQLConnection, by userId: Int, for articleSlug: String) -> Future<Article> {
        connection
            .raw( RawSQLQueries.insertFavorites(for: articleSlug, by: userId ) )
            .all()
            .flatMap { _ in
                connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
            }
            .map { rows in
                guard let row = rows.first else {
                    throw Error("Insert process is failed. Article is not found. Logically impossible.", status: 500)
                }
                return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
            }
    }

    /// Delete favorite into MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter userId: Id of the user to remove favorite.
    /// - Parameter articleSlug: Slug of article to remove favorite.
    /// - returns:
    ///    <#Description#>
    func deleteFavorite(on connection: MySQLConnection, by userId: Int, for articleSlug: String) -> Future<Article> {
        connection
            .raw( RawSQLQueries.deleteFavorites(for: articleSlug, by: userId ) )
            .all()
            .flatMap { _ in
                connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
            }
            .map { rows in
                guard let row = rows.first else {
                    throw Error("Delete process is failed. Article is not found. Logically impossible.", status: 500)
                }
                return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
            }
    }

    /// Queries MySQL Database for Comments on Articles.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter articleSlug: Slug of the commented article.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    <#Description#>
    func selectComments(on connection: MySQLConnection, for articleSlug: String, readit userId: Int? = nil) -> Future<[Comment]> {
        connection
            .raw( RawSQLQueries.selectComments(for: articleSlug, readIt: userId) )
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
    ///    <#Description#>
    func insertComment(on connection: MySQLConnection, for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        var inserted: Comments?
        return Articles
            .query(on: connection)
            .filter(\Articles.slug == articleSlug)
            .all()
            .flatMap { articles -> Future<Comments> in
                guard let article = articles.first else {
                    throw Error( "No article to comment was found", status: 404)
                }
                return Comments(body: body, author: userId, article: article.id! ).save(on: connection)
            }
            .flatMap { comment in
                Comments.query(on: connection).filter(\Comments.id == comment.id!).all()
            }
            .flatMap { comments -> Future<Users> in
                guard let comment = comments.first else {
                    throw Error( "The comment was saved successfully, but fluent did not return a value.", status: 500)
                }
                inserted = comment
                return comment.commentedUser.get(on: connection)
            }
            .map { author in
                Comment(_id: inserted!.id!, createdAt: inserted!.createdAt!, updatedAt: inserted!.updatedAt!, body: inserted!.body, author: Profile(username: author.username, bio: author.bio, image: author.image, following: false /* Because It's own. */))
            }
    }

    /// Delete Comments in MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter commentId: ID of comment to remove.
    /// - returns:
    ///    <#Description#>
    func deleteComments(on connection: MySQLConnection, commentId: Int ) -> Future<Void> {
        connection
            .raw( RawSQLQueries.deleteComments( id: commentId ) )
            .all()
            .map { _ in return }
    }

    /// Query MySQL Database for Articles.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter condition: Condition used to search for articles.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - Parameter offset: Offset to search results. nil means unspecified.
    /// - Parameter limit: Limit to search results. nil means unspecified.
    /// - returns:
    ///    <#Description#>
    func selectArticles(on connection: MySQLConnection, condition: ArticleCondition, readIt userId: Int? = nil, offset: Int? = nil, limit: Int? = nil) -> Future<[Article]> {
        connection
            .raw( RawSQLQueries.selectArticles(condition: condition, readIt: userId, offset: offset, limit: limit) )
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
    ///    <#Description#>
    func insertArticle(on connection: MySQLConnection, author: Int, title: String, slug: String, description: String, body: String, tags: [String], readIt userId: Int? = nil) -> Future<Article> {

        let eventLoop = connection.eventLoop
        return Articles(id: nil, slug: slug, title: title, description: description, body: body, author: author)
            .save(on: connection)
            .flatMap { article -> Future<Void> in
                let insertTags = tags.map { Tags(id: nil, article: article.id!, tag: $0 ).save(on: connection).map { _ in return } }
                switch insertTags.serializedFuture() {
                    case .some(let futures): return futures
                    case .none: return eventLoop.newSucceededFuture(result: Void())
                }
            }
            .flatMap { [weak self] _ -> Future<[Article]> in
                self!.selectArticles(on: connection, condition: .slug(slug), readIt: userId )
            }
            .map { articles -> Article in
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
    ///    <#Description#>
    func updateArticle(on connection: MySQLConnection, slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article> {
        // Define update article process
        let future = Articles.query(on: connection)
            .filter(\Articles.slug == slug)
            .all()
            .flatMap { rows -> Future<Articles> in
                guard let target = rows.first else {
                    throw Error( "Update process is failed. Article is not found. Logically impossible.", status: 500)
                }

                // Update Article
                if let t = title { target.title = t }
                if let d = description { target.description = d }
                if let b = body { target.body = b }

                return target.update(on: connection)
            }

        // Define finishing process
        let getArticlesClosure: (Any) -> Future<[Article]> = { [weak self](_) -> Future<[Article]> in
            self!.selectArticles(on: connection, condition: .slug(slug), readIt: userId)
        }
        let pickArticleClosure: ([Article]) throws -> Article = { articles in
            guard let article = articles.first else {
                throw Error("Update process is successed. But article is not found. Logically impossible.", status: 500)
            }
            return article
        }

        // has tagList?
        if let tagList = tagList {
            // Update Tags
            let eventLoop = future.eventLoop
            var articleId: Int?
            return future
                .flatMap { article -> EventLoopFuture<[Tags]> in
                    articleId = article.id
                    return try article.tags.query(on: connection).all()
                }
                .flatMap { tags -> EventLoopFuture<Void> in
                    let deleteFutures = tags.filter { tagList.contains($0.tag) == false }
                                            .map { $0.delete(on: connection) }
                    let saveFutures = tagList.filter { tags.map { $0.tag }.contains($0) == false }
                                            .map { Tags(id: nil, article: articleId!, tag: $0).save(on: connection).transform(to: Void()) }
                    return (deleteFutures + saveFutures).serializedFuture() ?? eventLoop.newSucceededFuture(result: Void())
                }
                .flatMap( getArticlesClosure )
                .map( pickArticleClosure )
        } else {
            return future
                .flatMap( getArticlesClosure )
                .map( pickArticleClosure )
        }
    }

    /// Delete Articles in MySQL Database.
    /// - Parameter connection: A valid connection to MySQL.
    /// - Parameter slug: Slug of article to be deleted.
    /// - returns:
    ///    <#Description#>
    func deleteArticle(on connection: MySQLConnection, slug: String ) -> Future<Void> {
        connection
            .raw( RawSQLQueries.deleteArticles(slug: slug) )
            .all()
            .map { _ in return }
    }

    /// Query MySQL Database for all tags.
    /// - Parameter connection: A valid connection to MySQL.
    /// - returns:
    ///    <#Description#>   
    func selectTags(on connection: MySQLConnection) -> Future<[String]> {
        connection
            .raw( RawSQLQueries.selectTags() )
            .all(decoding: TagOnlyRow.self )
            .map { rows in rows.map { $0.tag } }
    }
}
