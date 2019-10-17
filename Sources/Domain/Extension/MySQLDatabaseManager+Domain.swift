//
//  MySQLDatabaseManager+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//

import Infrastructure
import FluentMySQL

extension MySQLDatabaseManager{
    
    func selectUser(email: String) throws -> Users?{
        return try Users.query(on: try newConnection()).filter(\Users.email == email).all().wait().first
    }
    
    func selectUser(id: Int) throws -> Users?{
        return try Users.query(on: try newConnection()).filter(\Users.id == id).all().wait().first
    }
    
    func insertUser(name username: String, email: String, hash: String, salt: String) throws -> Users? {
        return
            try Users(id: nil, username: username, email: email, hash: hash, salt: salt)
            .save(on: try newConnection())
            .wait()
    }
    
    func updateUser(id: Int, email: String, bio: String, image: String) throws -> Users?{

        let connection = try newConnection()
        guard let row = try Users.query(on: connection).filter(\Users.id == id).all().wait().first else{
            return nil
        }
            
        row.email = email
        row.bio   = bio
        row.image = image
        
        return try row.update(on: connection ).wait()
    }
    
    
    func selectProfile(username: String, readIt userId: Int?) throws -> Profile?{
        let connection = try newConnection()
        guard
            let row = try connection.raw( RawSQLQueries.selectUsers(name: username, follower: userId) )
            .all(decoding: UserWithFollowRow.self )
            .wait()
            .first else{
            return nil
        }
        return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
    }
    
    func insertFollow(followee username: String, follower userId: Int ) throws -> Profile?{
        let connection = try newConnection()
        _ = try connection.raw( RawSQLQueries.insertFollows(followee: username, follower: userId) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectUsers(name: username, follower: userId) ).all(decoding: UserWithFollowRow.self).wait().first else{
            return nil
        }
        return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
    }
    
    func insertFollow2(followee username: String, follower userId: Int ) throws -> Profile?{
        let connection = try newConnection()
        guard let followee = try Users.query(on: connection).decode(data: UserWithFollowRow.self).filter(\Users.username == username).all().wait().first else{
            return nil
        }
        let follow = try Follows(id: nil, followee: followee.id, follower: userId).save(on: connection).wait()
        return Profile(username: followee.username, bio: followee.bio, image: followee.image, following:  follow.followee == followee.id )
    }
    
    func deleteFollow(followee username: String, follower userId: Int ) throws -> Profile?{
        let connection = try newConnection()
        _ = try connection.raw( RawSQLQueries.deleteFollows(followee: username, follower: userId) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectUsers(name: username, follower: userId) ).all(decoding: UserWithFollowRow.self).wait().first else{
            return nil
        }
        return Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false)
    }
    
    
    func insertFavorite(by userId: Int, for articleSlug: String) throws -> Article?{
        let connection = try newConnection()
        _ = try connection.raw( RawSQLQueries.insertFavorites(for: articleSlug, by: userId ) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait().first else{
            return nil
        }
        return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
    }
    
    func deleteFavorite(by userId: Int, for articleSlug: String) throws -> Article?{
        let connection = try newConnection()
        _ = try connection.raw( RawSQLQueries.deleteFavorites(for: articleSlug, by: userId ) ).all().wait()
        guard
            let row = try connection.raw( RawSQLQueries.selectArticles(condition: .slug(articleSlug), readIt: userId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait().first else{
            return nil
        }
        return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
    }
    
    // TODO: Comment with User
    func selectComments(for articleSlug: String, readit userId: Int ) throws -> [Comment]{
        let connection = try newConnection()
        let rows = try connection.raw( RawSQLQueries.selectComments(for: articleSlug) ).all(decoding: Comments.self).wait()
        
        return try rows.compactMap { (comment: Comments) -> Comment? in
            guard
                let user = try connection.raw( RawSQLQueries.selectUsers(id: comment.author, follower: userId) ).all(decoding: UserWithFollowRow.self).wait().first else {
                return nil
            }
            return Comment(_id: comment.id!, createdAt: comment.createdAt!, updatedAt: comment.updatedAt!, body: comment.body, author: Profile(username: user.username, bio: user.bio, image: user.image, following: user.following ?? false))
        }
    }
    
    // TODO: Insert
    
    func deleteComments( commentId: Int ) throws{
        _ = try (try newConnection()).raw( RawSQLQueries.deleteComments( id: commentId ) ).all().wait().first
    }
    
    
    private func selectArticles( condition: RawSQLQueries.ArticleCondition, readIt userId: Int?) throws -> [Article]{
        let rows = try (try newConnection()).raw( RawSQLQueries.selectArticles(condition: condition, readIt: userId)  ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        return rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
    }
    
    func selectArticles( follower id: Int, readIt userId: Int?) throws -> [Article]{
        return try selectArticles(condition: .feed(id), readIt: userId)
    }
    
    func selectArticles( author username: String, readIt userId: Int?) throws -> [Article]{
        return try selectArticles(condition: .author(username), readIt: userId)
    }
    
    func selectArticles( tag: String, readIt userId: Int?) throws -> [Article]{
        return try selectArticles(condition: .tag(tag), readIt: userId)
    }
    
    func selectArticles( favorite username: String, readIt userId: Int?) throws -> [Article]{
        return try selectArticles(condition: .favorite(username), readIt: userId)
    }
    
    func selectArticles( slug: String, readIt userId: Int?) throws -> Article?{
        return try selectArticles(condition: .slug(slug), readIt: userId).first
    }
    
    func insertArticle(author: Int, title: String, slug: String, description: String, body: String, tags: [String], readIt userId: Int? ) throws -> Article?{
        let connection = try newConnection()
        
        _ = try connection.simpleQuery("START TRANSACTION").wait()
        
        let article = try Articles(id: nil, slug: slug, title: title, description: description, body: body, author: author).save(on: connection).wait()
        
        let orders = tags.map{ Tags(id: nil, article: article.id!, tag: $0 ).save(on: connection) }
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer{
            evGroup.shutdownGracefully { (error) in
                // TODO: notify to system
                if let error = error{ print(error) }
            }
        }
        let allFuture = EventLoopFuture.whenAll(orders, eventLoop: evGroup.next()).map { tags in
            return
        }
        allFuture.whenFailure { (error) in
            // TODO: notify to system
            print(error)
            do{
                _ = try connection.simpleQuery("ROLLBACK").wait()
            }catch(let rollbackError){
                // TODO: notify to system
                print(rollbackError)
            }
        }
        
        try allFuture.wait()
        return try selectArticles( slug: slug, readIt: userId)
    }
    
    func deleteArticle( slug: String ) throws {
        _ = try (try newConnection()).raw( RawSQLQueries.deleteArticles(slug: slug) ).all().wait()
    }
}
