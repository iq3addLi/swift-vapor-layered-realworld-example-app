//
//  MySQLDatabaseManager+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//

import Infrastructure
import FluentMySQL

extension MySQLDatabaseManager{
    
    func selectUser(on connection: MySQLConnection, email: String) throws -> Users?{
        return try Users.query(on: connection).filter(\Users.email == email).all().wait().first
    }
    
    func selectUser(on connection: MySQLConnection, id: Int) throws -> Users?{
        return try Users.query(on: connection).filter(\Users.id == id).all().wait().first
    }
    
    func insertUser(on connection: MySQLConnection, name username: String, email: String, hash: String, salt: String) throws -> Users? {
        return
            try Users(id: nil, username: username, email: email, hash: hash, salt: salt)
            .save(on: connection)
            .wait()
    }
    
    func updateUser(on connection: MySQLConnection, id: Int, email: String, bio: String, image: String) throws -> Users?{

        guard let row = try Users.query(on: connection).filter(\Users.id == id).all().wait().first else{
            return nil
        }
            
        row.email = email
        row.bio   = bio
        row.image = image
        
        return try row.update(on: connection ).wait()
    }
    
    
    func selectProfile(on connection: MySQLConnection, username: String, readIt userId: Int? = nil) throws -> Profile?{
        guard
            let row = try connection.raw( RawSQLQueries.selectUsers(name: username, follower: userId) )
            .all(decoding: UserWithFollowRow.self )
            .wait()
            .first else{
            return nil
        }
        return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
    }
    
    func insertFollow(on connection: MySQLConnection, followee username: String, follower userId: Int ) throws -> Profile?{
        _ = try connection.raw( RawSQLQueries.insertFollows(followee: username, follower: userId) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectUsers(name: username, follower: userId) ).all(decoding: UserWithFollowRow.self).wait().first else{
            return nil
        }
        return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
    }
    
    func insertFollow2(on connection: MySQLConnection, followee username: String, follower userId: Int ) throws -> Profile?{
        guard let followee = try Users.query(on: connection).decode(data: UserWithFollowRow.self).filter(\Users.username == username).all().wait().first else{
            return nil
        }
        let follow = try Follows(id: nil, followee: followee.id, follower: userId).save(on: connection).wait()
        return Profile(username: followee.username, bio: followee.bio, image: followee.image, following:  follow.followee == followee.id )
    }
    
    func deleteFollow(on connection: MySQLConnection, followee username: String, follower userId: Int ) throws -> Profile?{
        _ = try connection.raw( RawSQLQueries.deleteFollows(followee: username, follower: userId) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectUsers(name: username, follower: userId) ).all(decoding: UserWithFollowRow.self).wait().first else{
            return nil
        }
        return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
    }
    
    
    func insertFavorite(on connection: MySQLConnection, by userId: Int, for articleSlug: String) throws -> Article?{
        _ = try connection.raw( RawSQLQueries.insertFavorites(for: articleSlug, by: userId ) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait().first else{
            return nil
        }
        return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
    }
    
    func deleteFavorite(on connection: MySQLConnection, by userId: Int, for articleSlug: String) throws -> Article?{
        _ = try connection.raw( RawSQLQueries.deleteFavorites(for: articleSlug, by: userId ) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait().first else{
            return nil
        }
        return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
    }
    
    func selectComments(on connection: MySQLConnection, for articleSlug: String, readit userId: Int? = nil) throws -> [Comment]{
        let rows = try connection.raw( RawSQLQueries.selectComments(for: articleSlug, readIt: userId) ).all(decoding: CommentWithAuthorRow.self).wait()
        return rows.map { comment in
            Comment(_id: comment.id, createdAt: comment.createdAt, updatedAt: comment.updatedAt, body: comment.body, author: Profile(username: comment.username, bio: comment.bio, image: comment.image, following: comment.following ?? false))
        }
    }
    
    // TODO: Insert
    
    func deleteComments(on connection: MySQLConnection, commentId: Int ) throws{
        _ = try connection.raw( RawSQLQueries.deleteComments( id: commentId ) ).all().wait().first
    }
    
    
    private func selectArticles(on connection: MySQLConnection, condition: RawSQLQueries.ArticleCondition, readIt userId: Int?) throws -> [Article]{
        let rows = try connection.raw( RawSQLQueries.selectArticles(condition: condition, readIt: userId)  ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        return rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
    }
    
    func selectArticles(on connection: MySQLConnection, follower id: Int, readIt userId: Int? = nil) throws -> [Article]{
        return try selectArticles(on: connection, condition: .feed(id), readIt: userId)
    }
    
    func selectArticles(on connection: MySQLConnection, author username: String, readIt userId: Int? = nil) throws -> [Article]{
        return try selectArticles(on: connection, condition: .author(username), readIt: userId)
    }
    
    func selectArticles(on connection: MySQLConnection, tag: String, readIt userId: Int? = nil) throws -> [Article]{
        return try selectArticles(on: connection, condition: .tag(tag), readIt: userId)
    }
    
    func selectArticles(on connection: MySQLConnection, favorite username: String, readIt userId: Int? = nil) throws -> [Article]{
        return try selectArticles(on: connection, condition: .favorite(username), readIt: userId)
    }
    
    func selectArticles(on connection: MySQLConnection, slug: String, readIt userId: Int? = nil) throws -> Article?{
        return try selectArticles(on: connection, condition: .slug(slug), readIt: userId).first
    }
    
    func insertArticle(on connection: MySQLConnection, author: Int, title: String, slug: String, description: String, body: String, tags: [String], readIt userId: Int? = nil) throws -> Article?{

        // insert article
        let article = try Articles(id: nil, slug: slug, title: title, description: description, body: body, author: author).save(on: connection).wait()
        
        // insert tags
        let orders = tags.map{ Tags(id: nil, article: article.id!, tag: $0 ).save(on: connection) }
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer{
            evGroup.shutdownGracefully { (error) in
                // TODO: notify to system
                if let error = error{ print(error) }
            }
        }
        let allFuture = EventLoopFuture.whenAll(orders, eventLoop: evGroup.next())
        
        // All future closure execute
        _ = try allFuture.wait()
        return try selectArticles(on: connection, slug: slug, readIt: userId)
    }
    
    func deleteArticle(on connection: MySQLConnection, slug: String ) throws {
        _ = try connection.raw( RawSQLQueries.deleteArticles(slug: slug) ).all().wait()
    }
}

// MARK: TRANSACTION
extension MySQLDatabaseManager{

    func startTransaction<T>(_ transactionClosure:(_ connection: MySQLConnection) throws -> T, completionClosure:(T) -> Void, failureClosure: (Error) -> Void){
        // Connection and start transaction
        let connection: MySQLConnection
        do {
            connection = try newConnection()
             _ = try connection.simpleQuery("START TRANSACTION").wait()
        }catch( let error ){
            /* TODO: Notify to system */
            failureClosure( error ); return
        }
        
        // Execute transaction
        let result: T
        do {
            result = try transactionClosure(connection)
        }catch( let error ){
            do{ _ = try connection.simpleQuery("ROLLBACK").wait() } catch { /* TODO: Notify to system */ }
            failureClosure( error ); return 
        }
        do{ _ = try connection.simpleQuery("COMMIT").wait() } catch { /* TODO: Notify to system */ }
        completionClosure(result)
    }
}
