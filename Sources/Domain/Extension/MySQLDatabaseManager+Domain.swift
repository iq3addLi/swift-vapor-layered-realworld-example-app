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
    
    func insertUser(on connection: MySQLConnection, name username: String, email: String, hash: String, salt: String) throws -> Users {
        return
            try Users(id: nil, username: username, email: email, hash: hash, salt: salt)
            .save(on: connection)
            .wait()
    }
    
    func updateUser(on connection: MySQLConnection, id: Int, email: String?, bio: String?, image: String?) throws -> Users?{

        guard let row = try Users.query(on: connection).filter(\Users.id == id).all().wait().first else{
            return nil
        }
            
        if let email = email { row.email = email }
        if let bio = bio { row.bio = bio }
        if let image = image { row.image = image }
        
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
    
    func insertComment(on connection: MySQLConnection, for articleSlug: String, body: String, author userId: Int) throws -> Comment{
        
        guard let article = try Articles.query(on: connection).filter(\Articles.slug == articleSlug).all().wait().first else{
            throw Error( "No article to comment was found")
        }
        let inserted = try Comments(body: body, author: userId, article: article.id! ).save(on: connection).wait() // MEMO: Return value's timestamp is nil when insert😣 So need to select again😩
        guard let comment = try Comments.query(on: connection).filter(\Comments.id == inserted.id!).all().wait().first else{
            throw Error( "The comment was saved successfully, but fluent did not return a value.")
        }
        guard let author = try inserted.commentedUser?.get(on: connection).wait() else{
            throw Error( "Failed to get commented user.")
        }
        
        return Comment(_id: comment.id!, createdAt: comment.createdAt!, updatedAt: comment.updatedAt!, body: comment.body, author: Profile(username: author.username, bio: author.bio, image: author.image, following: false /* Because It's own. */))
    }
    
    func deleteComments(on connection: MySQLConnection, commentId: Int ) throws{
        _ = try connection.raw( RawSQLQueries.deleteComments( id: commentId ) ).all().wait().first
    }
    
    
    func selectArticles(on connection: MySQLConnection, condition: ArticleCondition, readIt userId: Int? = nil, offset: Int? = nil, limit: Int? = nil) throws -> [Article]{
        let rows = try connection.raw( RawSQLQueries.selectArticles(condition: condition, readIt: userId, offset: offset, limit: limit) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        return rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
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
        return try selectArticles(on: connection, condition: .slug(slug), readIt: userId ).first
    }
    
    func updateArticle(on connection: MySQLConnection, slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) throws -> Article{
        
        // Search Articles
        guard let target = try Articles.query(on: connection).filter(\Articles.slug == slug).all().wait().first else{
            throw Error( "Article is not found")
        }
        
        // Update Article
        if let t = title { target.title = t }
        if let d = description { target.description = d }
        if let b = body { target.body = b }
        
        let _ = try target.update(on: connection).wait()
        
        // Update Tags
        if let tagList = tagList {
            let tags = try target.tags.query(on: connection).all().wait()
            
            try tags.filter{ tagList.contains($0.tag) == false }
                    .forEach{ try $0.delete(on: connection).wait() }
            try tagList.filter{ tags.map{ $0.tag }.contains($0) == false }
                    .forEach{ _ = try Tags(id: nil, article: target.id!, tag: $0).save(on: connection).wait() }
        }
        
        // Search Article properties
        guard let article = try selectArticles(on: connection, condition: .slug(slug), readIt: userId).first else{
            throw Error( "Article is not found when after update.")
        }
        return article
    }
    
    func deleteArticle(on connection: MySQLConnection, slug: String ) throws {
        _ = try connection.raw( RawSQLQueries.deleteArticles(slug: slug) ).all().wait()
    }
    
    func selectTags(on connection: MySQLConnection) throws -> [String]{
        return try connection.raw( RawSQLQueries.selectTags() )
            .all(decoding: TagOnlyRow.self )
            .wait()
            .map{ $0.tag }
    }
}
