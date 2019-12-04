//
//  MySQLDatabaseManager+manageConnection.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/27.
//

import Infrastructure

/// Extensions required by Domain
extension MySQLDatabaseManager {

    // MARK: Manage connection
    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter email: A email address. Information to identify the user.
    func selectUser(email: String) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, email: email)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter id: A user id. Information to identify the user.
    func selectUser(id: Int) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, id: id)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter name: A user name. Information to identify the user.
    func selectUser(name: String) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, username: name)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameters:
    ///   - username: New user name to register
    ///   - email: New email to register
    ///   - hash: Hashed password
    ///   - salt: Salt used when hashing
    func insertUser(name username: String, email: String, hash: String, salt: String) -> Future<Users> {
        startTransaction { connection in
            self.insertUser(on: connection, name: username, email: email, hash: hash, salt: salt)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameters:
    ///   - id: ID of User to be updated
    ///   - email: New email. No update if nil.
    ///   - bio: New bio. No update if nil.
    ///   - image: New image. No update if nil.
    func updateUser(id: Int, email: String?, bio: String?, image: String?) -> Future<Users> {
        startTransaction { connection in
            self.updateUser(on: connection, id: id, email: email, bio: bio, image: image)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter username: A user name. Information to identify the user
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information
    func selectProfile(username: String, readIt userId: Int? = nil) -> Future<Profile?> {
        communication { connection in
            self.selectProfile(on: connection, username: username, readIt: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter username: A user name of followee
    /// - Parameter userId: A user id of follower
    func insertFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        startTransaction { connection in
            self.insertFollow(on: connection, followee: username, follower: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter username: A user name of followee.
    /// - Parameter userId: <#userId description#>
    func deleteFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        startTransaction { connection in
            self.deleteFollow(on: connection, followee: username, follower: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func insertFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        startTransaction { connection in
            self.insertFavorite(on: connection, by: userId, for: articleSlug)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter userId: <#userId description#>
    /// - Parameter articleSlug: <#articleSlug description#>
    func deleteFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        startTransaction { connection in
            self.deleteFavorite(on: connection, by: userId, for: articleSlug)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter userId: <#userId description#>
    func selectComments(for articleSlug: String, readit userId: Int? = nil) -> Future<[Comment]> {
        communication { connection in
            self.selectComments(on: connection, for: articleSlug, readit: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - Parameter body: <#body description#>
    /// - Parameter userId: <#userId description#>
    func insertComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        startTransaction { connection in
            self.insertComment(on: connection, for: articleSlug, body: body, author: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter commentId: <#commentId description#>
    func deleteComments(commentId: Int ) -> Future<Void> {
        startTransaction { connection in
            self.deleteComments(on: connection, commentId: commentId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter condition: <#condition description#>
    /// - Parameter userId: <#userId description#>
    /// - Parameter offset: <#offset description#>
    /// - Parameter limit: <#limit description#>
    func selectArticles(condition: ArticleCondition, readIt userId: Int? = nil, offset: Int? = nil, limit: Int? = nil) -> Future<[Article]> {
        startTransaction { connection in
            self.selectArticles(on: connection, condition: condition, readIt: userId, offset: offset, limit: limit)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
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

    /// Get a valid connection to MySQL from the manager and send a query.
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

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter slug: <#slug description#>
    func deleteArticle(slug: String ) -> Future<Void> {
        startTransaction { connection in
            self.deleteArticle(on: connection, slug: slug)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    func selectTags() -> Future<[String]> {
        communication { connection in
            self.selectTags(on: connection)
        }
    }
}
