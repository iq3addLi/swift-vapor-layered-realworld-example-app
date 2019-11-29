//
//  MySQLDatabaseManager+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//

import Infrastructure
import FluentMySQL

extension MySQLDatabaseManager {

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter email: <#email description#>
    func selectUser(on connection: MySQLConnection, email: String) -> Future<Users?> {
        Users
            .query(on: connection)
            .filter(\Users.email == email)
            .all()
            .map { $0.first }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter id: <#id description#>
    func selectUser(on connection: MySQLConnection, id: Int) -> Future<Users?> {
        Users
            .query(on: connection)
            .filter(\Users.id == id)
            .all()
            .map { $0.first }
    }

    func selectUser(on connection: MySQLConnection, username: String) -> Future<Users?> {
        Users
            .query(on: connection)
            .filter(\Users.username == username)
            .all()
            .map { $0.first }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter email: <#email description#>
    /// - Parameter hash: <#hash description#>
    /// - Parameter salt: <#salt description#>
    func insertUser(on connection: MySQLConnection, name username: String, email: String, hash: String, salt: String) -> Future<Users> {
        Users(id: nil, username: username, email: email, hash: hash, salt: salt)
            .save(on: connection)
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter id: <#id description#>
    /// - Parameter email: <#email description#>
    /// - Parameter bio: <#bio description#>
    /// - Parameter image: <#image description#>
    func updateUser(on connection: MySQLConnection, id: Int, email: String?, bio: String?, image: String?) -> Future<Users> {
        Users
            .query(on: connection)
            .filter(\Users.id == id)
            .first()
            .map { users -> Users in
                guard let user = users else {
                    throw Error("Update process is failed. User not found.")
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

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
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

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func insertFollow(on connection: MySQLConnection, followee username: String, follower userId: Int ) -> Future<Profile> {
        var followee: Users?
        return Users
            .query(on: connection)
            .filter(\Users.username == username)
            .all()
            .flatMap { rows -> Future<Follows> in
                guard let row = rows.first else {
                    throw Error("Insert process is failed. Followee is not found.")
                }
                followee = row
                return Follows(id: nil, followee: row.id!, follower: userId).save(on: connection)
            }
            .map { follow in
                Profile(username: followee!.username, bio: followee!.bio, image: followee!.image, following: follow.followee == followee!.id )
            }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func deleteFollow(on connection: MySQLConnection, followee username: String, follower userId: Int ) -> Future<Profile> {
        connection
            .raw( RawSQLQueries.deleteFollows(followee: username, follower: userId) )
            .all()
            .flatMap { _ in
                connection.raw( RawSQLQueries.selectUser(name: username, follower: userId) ).all(decoding: UserWithFollowRow.self)
            }
            .map { rows in
                guard let user = rows.first else {
                    throw Error("Delete process is failed. Followee is not found. Logically impossible.")
                }
                return Profile(username: user.username, bio: user.bio, image: user.image, following: user.following ?? false)
            }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func insertFavorite(on connection: MySQLConnection, by userId: Int, for articleSlug: String) -> Future<Article> {
        connection
            .raw( RawSQLQueries.insertFavorites(for: articleSlug, by: userId ) )
            .all()
            .flatMap { _ in
                connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
            }
            .map { rows in
                guard let row = rows.first else {
                    throw Error("Insert process is failed. Article is not found. Logically impossible.")
                }
                return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
            }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func deleteFavorite(on connection: MySQLConnection, by userId: Int, for articleSlug: String) -> Future<Article> {
        connection
            .raw( RawSQLQueries.deleteFavorites(for: articleSlug, by: userId ) )
            .all()
            .flatMap { _ in
                connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self)
            }
            .map { rows in
                guard let row = rows.first else {
                    throw Error("Delete process is failed. Article is not found. Logically impossible.")
                }
                return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
            }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter userId: <#userId description#>
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

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter body: <#body description#>
    /// - Parameter userId: <#userId description#>
    func insertComment(on connection: MySQLConnection, for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        var inserted: Comments?
        return Articles
            .query(on: connection)
            .filter(\Articles.slug == articleSlug)
            .all()
            .flatMap { articles -> Future<Comments> in
                guard let article = articles.first else {
                    throw Error( "No article to comment was found")
                }
                return Comments(body: body, author: userId, article: article.id! ).save(on: connection)
            }
            .flatMap { comment in
                Comments.query(on: connection).filter(\Comments.id == comment.id!).all()
            }
            .flatMap { comments -> Future<Users> in
                guard let comment = comments.first else {
                    throw Error( "The comment was saved successfully, but fluent did not return a value.")
                }
                inserted = comment
                return comment.commentedUser.get(on: connection)
            }
            .map { author in
                Comment(_id: inserted!.id!, createdAt: inserted!.createdAt!, updatedAt: inserted!.updatedAt!, body: inserted!.body, author: Profile(username: author.username, bio: author.bio, image: author.image, following: false /* Because It's own. */))
            }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter commentId: <#commentId description#>
    func deleteComments(on connection: MySQLConnection, commentId: Int ) -> Future<Void> {
        connection
            .raw( RawSQLQueries.deleteComments( id: commentId ) )
            .all()
            .map { _ in return }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter condition: <#condition description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter offset: <#offset description#>
    /// - Parameter limit: <#limit description#>
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

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter author: <#author description#>
    /// - Parameter title: <#title description#>
    /// - Parameter slug: <#slug description#>
    /// - Parameter description: <#description description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tags: <#tags description#>
    /// - Parameter userId: <#userId description#>
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
                    throw Error( "The article was saved successfully, but fluent did not return a value.")
                }
                return article
            }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter slug: <#slug description#>
    /// - Parameter title: <#title description#>
    /// - Parameter description: <#description description#>
    /// - Parameter body: <#body description#>
    /// - Parameter tagList: <#tagList description#>
    /// - Parameter userId: <#userId description#>
    func updateArticle(on connection: MySQLConnection, slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article> {
        // Update article
        let future = Articles.query(on: connection)
            .filter(\Articles.slug == slug)
            .all()
            .flatMap { rows -> Future<Articles> in
                guard let target = rows.first else {
                    throw Error( "Update process is failed. Article is not found. Logically impossible.")
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
                throw Error("Update process is successed. But article is not found. Logically impossible.")
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

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter slug: <#slug description#>
    func deleteArticle(on connection: MySQLConnection, slug: String ) -> Future<Void> {
        connection
            .raw( RawSQLQueries.deleteArticles(slug: slug) )
            .all()
            .map { _ in return }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    func selectTags(on connection: MySQLConnection) -> Future<[String]> {
        connection
            .raw( RawSQLQueries.selectTags() )
            .all(decoding: TagOnlyRow.self )
            .map { rows in rows.map { $0.tag } }
    }
}
