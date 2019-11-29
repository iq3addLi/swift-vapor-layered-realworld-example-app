//
//  MySQLDatabaseManager+manageConnection.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/27.
//

import Infrastructure
import FluentMySQL

extension MySQLDatabaseManager {

    func selectUser(email: String) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, email: email)
        }
    }

    func selectUser(id: Int) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, id: id)
        }
    }

    func selectUser(name: String) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, username: name)
        }
    }

    func insertUser(name username: String, email: String, hash: String, salt: String) -> Future<Users> {
        startTransaction { connection in
            self.insertUser(on: connection, name: username, email: email, hash: hash, salt: salt)
        }
    }

    func updateUser(id: Int, email: String?, bio: String?, image: String?) -> Future<Users> {
        startTransaction { connection in
            self.updateUser(on: connection, id: id, email: email, bio: bio, image: image)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func selectProfile(username: String, readIt userId: Int? = nil) -> Future<Profile?> {
        communication { connection in
            self.selectProfile(on: connection, username: username, readIt: userId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func insertFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        startTransaction { connection in
            self.insertFollow(on: connection, followee: username, follower: userId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter username: <#username description#>
    /// - Parameter userId: <#userId description#>
    func deleteFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        startTransaction { connection in
            self.deleteFollow(on: connection, followee: username, follower: userId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func insertFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        startTransaction { connection in
            self.insertFavorite(on: connection, by: userId, for: articleSlug)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func deleteFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        startTransaction { connection in
            self.deleteFavorite(on: connection, by: userId, for: articleSlug)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter userId: <#userId description#>
    func selectComments(for articleSlug: String, readit userId: Int? = nil) -> Future<[Comment]> {
        communication { connection in
            self.selectComments(on: connection, for: articleSlug, readit: userId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter body: <#body description#>
    /// - Parameter userId: <#userId description#>
    func insertComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        startTransaction { connection in
            self.insertComment(on: connection, for: articleSlug, body: body, author: userId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter commentId: <#commentId description#>
    func deleteComments(commentId: Int ) -> Future<Void> {
        startTransaction { connection in
            self.deleteComments(on: connection, commentId: commentId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter condition: <#condition description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter offset: <#offset description#>
    /// - Parameter limit: <#limit description#>
    func selectArticles(condition: ArticleCondition, readIt userId: Int? = nil, offset: Int? = nil, limit: Int? = nil) -> Future<[Article]> {
        startTransaction { connection in
            self.selectArticles(on: connection, condition: condition, readIt: userId, offset: offset, limit: limit)
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
    func insertArticle(author: Int, title: String, slug: String, description: String, body: String, tags: [String], readIt userId: Int? = nil) -> Future<Article> {
        startTransaction { connection in
            self.insertArticle(on: connection, author: author, title: title, slug: slug, description: description, body: body, tags: tags)
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
    func updateArticle(slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article> {
        startTransaction { connection in
            self.updateArticle(on: connection, slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    /// - Parameter slug: <#slug description#>
    func deleteArticle(slug: String ) -> Future<Void> {
        startTransaction { connection in
            self.deleteArticle(on: connection, slug: slug)
        }
    }

    /// <#Description#>
    /// - Parameter connection: <#connection description#>
    func selectTags() -> Future<[String]> {
        communication { connection in
            self.selectTags(on: connection)
        }
    }
}
