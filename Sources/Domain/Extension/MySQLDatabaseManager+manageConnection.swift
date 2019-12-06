//
//  MySQLDatabaseManager+manageConnection.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/27.
//

import Infrastructure

// MARK: Manage connection

/// Extensions required by Domain
extension MySQLDatabaseManager {
    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter email: A email address. Information to identify the user.
    /// - returns:
    ///    <#Description#>
    func selectUser(email: String) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, email: email)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter id: A user id. Information to identify the user.
    /// - returns:
    ///    <#Description#>
    func selectUser(id: Int) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, id: id)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter name: A user name. Information to identify the user.
    /// - returns:
    ///    <#Description#>
    func selectUser(name: String) -> Future<Users?> {
        communication { connection in
            self.selectUser(on: connection, username: name)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameters:
    ///   - username: New user name to register.
    ///   - email: New email to register.
    ///   - hash: Hashed password.
    ///   - salt: Salt used when hashing.
    /// - returns:
    ///    <#Description#>
    func insertUser(name username: String, email: String, hash: String, salt: String) -> Future<Users> {
        transaction { connection in
            self.insertUser(on: connection, name: username, email: email, hash: hash, salt: salt)
        }
    }

    
    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameters:
    ///   - id: ID of User to be updated.
    ///   - email: New email. No update if nil.
    ///   - bio: New bio. No update if nil.
    ///   - image: New image. No update if nil.
    /// - returns:
    ///    <#Description#>
    func updateUser(id: Int, email: String?, bio: String?, image: String?) -> Future<Users> {
        transaction { connection in
            self.updateUser(on: connection, id: id, email: email, bio: bio, image: image)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter username: A user name. Information to identify the user.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    <#Description#>
    func selectProfile(username: String, readIt userId: Int? = nil) -> Future<Profile?> {
        communication { connection in
            self.selectProfile(on: connection, username: username, readIt: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter username: A user name of followee.
    /// - Parameter userId: A user id of follower.
    /// - returns:
    ///    <#Description#>
    func insertFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        transaction { connection in
            self.insertFollow(on: connection, followee: username, follower: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter username: A user name of followee.
    /// - Parameter userId: A user id of follower.
    /// - returns:
    ///    <#Description#>
    func deleteFollow(followee username: String, follower userId: Int ) -> Future<Profile> {
        transaction { connection in
            self.deleteFollow(on: connection, followee: username, follower: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter userId: A favorite userId.
    /// - Parameter articleSlug: A slug of favorite article.
    /// - returns:
    ///    <#Description#>
    func insertFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        transaction { connection in
            self.insertFavorite(on: connection, by: userId, for: articleSlug)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter userId: Id of the user to remove favorite.
    /// - Parameter articleSlug: Slug of article to remove favorite.
    /// - returns:
    ///    <#Description#>
    func deleteFavorite(by userId: Int, for articleSlug: String) -> Future<Article> {
        transaction { connection in
            self.deleteFavorite(on: connection, by: userId, for: articleSlug)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter articleSlug: Slug of the commented article.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    <#Description#>
    func selectComments(for articleSlug: String, readit userId: Int? = nil) -> Future<[Comment]> {
        communication { connection in
            self.selectComments(on: connection, for: articleSlug, readit: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter articleSlug: Slug of the article to comment.
    /// - Parameter body: Body of comment.
    /// - Parameter userId: Id of comment author.
    /// - returns:
    ///    <#Description#>
    func insertComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment> {
        transaction { connection in
            self.insertComment(on: connection, for: articleSlug, body: body, author: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter commentId: ID of comment to remove.
    /// - returns:
    ///    <#Description#>
    func deleteComments(commentId: Int ) -> Future<Void> {
        transaction { connection in
            self.deleteComments(on: connection, commentId: commentId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter condition: Condition used to search for articles.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - Parameter offset: Offset to search results. nil means unspecified.
    /// - Parameter limit: Limit to search results. nil means unspecified.
    /// - returns:
    ///    <#Description#>
    func selectArticles(condition: ArticleCondition, readIt userId: Int? = nil, offset: Int? = nil, limit: Int? = nil) -> Future<[Article]> {
        transaction { connection in
            self.selectArticles(on: connection, condition: condition, readIt: userId, offset: offset, limit: limit)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter author: Id of the new article author.
    /// - Parameter title: Title of the new article.
    /// - Parameter slug: Slug of the new article.
    /// - Parameter description: Description of the new article.
    /// - Parameter body: Body of the new article.
    /// - Parameter tags: Array of tag strings attached to new article.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    <#Description#>
    func insertArticle(author: Int, title: String, slug: String, description: String, body: String, tags: [String], readIt userId: Int? = nil) -> Future<Article> {
        transaction { connection in
            self.insertArticle(on: connection, author: author, title: title, slug: slug, description: description, body: body, tags: tags)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter slug: Slug of article to be updated.
    /// - Parameter title: Title of article to be updated, nil means unspecified.
    /// - Parameter description: Description of article to be updated, nil means unspecified.
    /// - Parameter body: Body of article to be updated, nil means unspecified.
    /// - Parameter tagList: Array of tag strings attached to be updated article, nil means unspecified.
    /// - Parameter userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    <#Description#>
    func updateArticle(slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article> {
        transaction { connection in
            self.updateArticle(on: connection, slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: userId)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - Parameter slug: Slug of article to be deleted.
    /// - returns:
    ///    <#Description#>
    func deleteArticle(slug: String ) -> Future<Void> {
        transaction { connection in
            self.deleteArticle(on: connection, slug: slug)
        }
    }

    /// Get a valid connection to MySQL from the manager and send a query.
    /// - returns:
    ///    <#Description#>   
    func selectTags() -> Future<[String]> {
        communication { connection in
            self.selectTags(on: connection)
        }
    }
}
