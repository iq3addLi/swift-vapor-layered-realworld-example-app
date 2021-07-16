//
//  FluentTests.swift
//  AppTests
//
//  Created by iq3AddLi on 2019/10/08.
//

import XCTest

@testable import Domain
import Infrastructure
import SwiftSlug
import FluentMySQLDriver

/*
 
 To pass this unit test, you will need to launch MySQL in a local environment.
 
 << Create database for UnitTests >>
 
 CREATE DATABASE database_for_unittest;
 CREATE USER 'unittest_user'@'%' IDENTIFIED BY 'unittest_userpass';
 GRANT ALL ON database_for_unittest.* TO 'unittest_user'@'%';
 
 */

let manager: MySQLDatabaseManager = {
    return MySQLDatabaseManager(
        hostname: "127.0.0.1",
        username: "unittest_user",
        password: "unittest_userpass",
        database: "database_for_unittest"
    )
}()

final class MySQLFluentTests: XCTestCase {
    
    static override func setUp() {
        do{
            // generate test tables
            let database = manager.mysql
            try Articles.create(on: database)
                .flatMap { Comments.create(on: database) }
                .flatMap { Favorites.create(on: database) }
                .flatMap { Follows.create(on: database) }
                .flatMap { Tags.create(on: database) }
                .flatMap { Users.create(on: database) }
                .wait()

            // generate test data
            
            // Test data for select
            let user1 = try manager.insertUser(name: "user_1", email: "user_1@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            
            // Test data for update
            let user2 = try manager.insertUser(name: "user_2", email: "user_2@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            
            // Test data for user relation
            let user3 = try manager.insertUser(name: "user_3", email: "user_3@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            let _ = try manager.insertFollow(followee: user1.username, follower: user3.id!).wait() // follow_user3_to_user1
            let _ = try manager.insertUser(name: "user_4", email: "user_4@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            
            // Test data for articles
            let article1 = try manager.insertArticle(author: user1.id!, title: "art_1", slug: "slug_1", description: "dummy", body: "dummy", tags: ["Vapor"]).wait()
            
            // Test data for comments
            let _ = try manager.insertComment(for: article1.slug, body: "I'm commented", author: user3.id!).wait() // comment_user3_to_user1's_article
            let _ = try manager.insertFollow(followee: user3.username, follower: user2.id!).wait() // follow_user2_to_user3
            
            // Test data for Tags
            let _ = try manager.insertArticle(author: user1.id!, title: "art_2", slug: "slug_2", description: "dummy", body: "dummy", tags: [ "Vapor", "Swift" ] ).wait() // favorite_user3_to_slug2_article
            
            // Test data for Favorites
            let _ = try manager.insertFavorite(by: user3.id!, for: article1.slug).wait()
            
            // Test data for delete Article
            let _ = try manager.insertArticle(author: user3.id!, title: "dummy", slug: "beDelete", description: "dummy", body: "dummy", tags: [ "Swift", "Fluent" ] ).wait()
            
        }catch{
            fatalError("\(#function)\n\(error)")
        }
    }
    
    static override func tearDown() {
        // clean test tables
        do{
            let database = manager.sql
            try database.drop(table: Articles.schema ).run().wait()
            try database.drop(table: Comments.schema ).run().wait()
            try database.drop(table: Favorites.schema ).run().wait()
            try database.drop(table: Follows.schema ).run().wait()
            try database.drop(table: Tags.schema ).run().wait()
            try database.drop(table: Users.schema ).run().wait()
        }catch{
            fatalError("\(#function)\n\(error)")
        }
    }
    
    static let allTests = [
        ("testSelectUserByEmail", testSelectUserByEmail),
        ("testInsertUser", testInsertUser),
        ("testSelectUserById", testSelectUserById),
        ("testUpdateUser", testUpdateUser),
        ("testSelectProfileByUsername", testSelectProfileByUsername),
        ("testInsertFollowsByUsername", testInsertFollowsByUsername),
        ("testDeleteFollowsByUsername", testDeleteFollowsByUsername),
        ("testFavoriteAndUnfavoriteBySlug", testFavoriteAndUnfavoriteBySlug),
        ("testSelectCommentsBySlug", testSelectCommentsBySlug),
        ("testDeleteCommentsBySlug", testDeleteCommentsBySlug),
        ("testSelectArticlesbyFollower", testSelectArticlesByFollower),
        ("testSelectArticlesByTag", testSelectArticlesByTag),
        ("testSelectArticlesByAuthor", testSelectArticlesByAuthor),
        ("testSelectArticlesInFavorite", testSelectArticlesInFavorite),
        ("testInsertArticle", testInsertArticle),
        ("testSelectArticleBySlug", testSelectArticleBySlug),
        ("testSelectArticleBySlugUsingFluent", testSelectArticleBySlugUsingFluent),
        ("testUpdateArticlebySlug", testUpdateArticleBySlug),
        ("testDeleteArticlebySlug", testDeleteArticleBySlug),
        ("testSelectTags", testSelectTags),
    ]
    
    func testSelectUserByEmail() throws {
        
        // Variables
        let email = "user_1@realworld_test.app"
        
        // Quering
        guard let user = try manager.selectUser(email: email).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertEqual(user.username, "user_1")
    }
    
    func testInsertUser() throws{
        // Variables
        let username = String.random(length: 8)
        let email = "\(username)@realworld_test.com"
        
        // Quering
        let user = try manager.insertUser(name: username, email: email, hash: "dummy", salt: "dummy").wait()
        
        // Examining
        XCTAssertNotEqual(user.id, .none)
        XCTAssertEqual(user.username, username)
    }
    
    func testSelectUserById() throws {
        // Variables
        let readItUser = 1
        
        // Quering
        guard let user = try manager.selectUser(id: readItUser).wait() else{
            XCTFail(); return
        }
        XCTAssertEqual(user.username, "user_1")
    }
    
    func testUpdateUser() throws {
        // Variables
        let readItUser = 2
        let email = "updated@realworld_test.com"
        let bio   = "This bio is dummy."
        let image = "https://dummy.com/dummy_image.jpg"

        // Quering
        let user = try manager.updateUser(id: readItUser, email: email, bio: bio, image: image).wait()
        
        // Examining
        XCTAssertEqual(user.username, "user_2")
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.bio, bio)
        XCTAssertEqual(user.image, image)
    }
    
    func testSelectProfileByUsername() throws {
        // Variables
        let readItUser = 3
        let tergetUserName = "user_1"
        
        // Quering
        guard let profile = try manager.selectProfile(username: tergetUserName, readIt: readItUser).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertEqual(profile.username, "user_1")
        XCTAssertTrue(profile.following )
    }
    
    func testInsertFollowsByUsername() throws {
        // Variables
        let readItUser = 1
        let followerUserName = "user_1"
        let followeeUserName = "user_4"
        
        // Quering
        let followee = try manager.insertFollow(followee: followeeUserName, follower: readItUser).wait() // follow user_1 to user_4
        guard let follower = try manager.selectProfile(username: followerUserName).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertEqual(followee.username, followeeUserName)
        XCTAssertTrue(followee.following) // user_1 is follow to user_4
        XCTAssertEqual(follower.username, followerUserName)
        XCTAssertFalse(follower.following) // user_4 is not follow to user_1
    }
    
    func testDeleteFollowsByUsername() throws {
        // Variables
        let followeeUserName = "user_1"
        let followerUserId = 2
        let followerUserName = "user_2"
        
        // Follow
        let followee = try manager.insertFollow(followee: followeeUserName, follower: followerUserId).wait()
        guard let follower = try manager.selectProfile(username: followerUserName).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(followee.following) // user_1 is not follow to user_2
        XCTAssertFalse(follower.following) // user_2 is follow to user_1
        
        // Unfollow
        let exFollowee = try manager.deleteFollow(followee: followeeUserName, follower: followerUserId).wait()
        
        // Examining
        XCTAssertFalse(exFollowee.following) // user_2 is not follow to user_1
    }
    
    func testFavoriteAndUnfavoriteBySlug() throws {
        // Variables
        let readItUser = 2
        
        // Quering
        let inserted = try manager.insertArticle(author: 3, title: "dummy", slug: "dummy", description: "dummy", body: "dummy", tags: []).wait()
        let article = try manager.insertFavorite(by: readItUser, for: inserted.slug).wait()
        
        // Examining
        XCTAssertTrue(article.favorited )
        XCTAssertEqual(article.favoritesCount, 1)
        
        // Quering
        let article_after = try manager.deleteFavorite(by: readItUser, for: inserted.slug).wait()
        
        // Examining
        XCTAssertFalse(article_after.favorited )
        XCTAssertEqual(article_after.favoritesCount, 0)
    }
    
    
    func testSelectCommentsBySlug() throws {
        // user_2 reads user_3's comments on user_1's article.
        
        // Variables
        let readItUser = 2
        let commentedArticleSlug = "slug_1"
                
        // Quering
        let comments = try manager.selectComments(for: commentedArticleSlug, readit: readItUser).wait()
        
        // Examining
        guard let comment = comments.first else{
            throw Error("Article's comment is not found.")
        }
        XCTAssertEqual(comments.count, 1)
        XCTAssertEqual(comment.body, "I'm commented")
        XCTAssertEqual(comment.author.username, "user_3" )
        XCTAssertTrue(comment.author.following )
    }
    
    func testDeleteCommentsBySlug() throws {
        // Comment on A's article and then delete it.
        
        // Variables
        let body = "It's awesome!"
        let commentedUserId = 2
        let wasCommentedArticleSlug = "slug_1"
        
        // Add comment
        let comment = try manager.insertComment(for: wasCommentedArticleSlug, body: body, author: commentedUserId).wait()
        
        let before = try Comments
            .query(on: manager.fluent)
            .all()
            .wait()
        
        XCTAssertEqual( comment.body, body )
        XCTAssertEqual( comment.author.username, "user_\(commentedUserId)" )
        XCTAssertFalse( comment.author.following )
        XCTAssertEqual( before.count, 2 )
        
        // Delete comment
        try manager.deleteComments(commentId: comment._id).wait()
        
        // Examining
        let after = try Comments
            .query(on: manager.fluent)
            .all()
            .wait()
        
        XCTAssertEqual(after.count, 1 )
    }
    
    
    func testSelectArticlesByFollower() throws {
        // Variables
        let readItUser = 3
        
        // Querying
        let articles = try manager.selectArticles(condition: .feed(readItUser)).wait()
        
        // Examining
        XCTAssertEqual(articles.count, 2)
    }
    
    func testSelectArticlesByTag() throws {
        // Variables
        let tagString = "Vapor"
        
        // Querying
        let articles = try manager.selectArticles( condition: .tag(tagString)).wait()
        
        // Examining
        XCTAssertEqual(articles.count, 2)
    }
    
    func testSelectArticlesByAuthor() throws {
        // Variables
        let readItUser = 3
        let targetUsername = "user_1"
        
        // Querying
        let articles = try manager.selectArticles(condition: .author(targetUsername), readIt: readItUser).wait()
        
        // Examining
        XCTAssertEqual(articles.count, 2)
        
        guard
            let article1 = articles.filter({ $0.slug == "slug_1" }).first,
            let article2 = articles.filter({ $0.slug == "slug_2" }).first else{
            throw Error("\(targetUsername)'s article is unexpected.")
        }

        XCTAssertTrue(article1.favorited)
        XCTAssertEqual(article1.favoritesCount, 1)
        XCTAssertFalse(article2.favorited)
        XCTAssertEqual(article2.favoritesCount, 0)
    }
    
    func testSelectArticlesInFavorite() throws {
        // Variables
        let readItUser = 3
        let targetUsername = "user_3"
        
        // Case of don't specify a reader.
        let caseA = try manager.selectArticles(condition: .favorite(targetUsername)).wait()
        
        // Examining
        XCTAssertEqual(caseA.count, 1)
        if let article = caseA.first {
            XCTAssertFalse(article.favorited)
            XCTAssertEqual(article.favoritesCount, 1)
        }else{
            throw Error("\(targetUsername)'s favorited article is unexpected.")
        }
        
        // Case of specify a reader.
        let caseB = try manager.selectArticles(condition: .favorite(targetUsername), readIt: readItUser).wait()
        
        // Examining
        XCTAssertEqual(caseB.count, 1)
        if let article = caseB.first {
            XCTAssertTrue(article.favorited)
            XCTAssertEqual(article.favoritesCount, 1)
        }else{
            throw Error("\(targetUsername)'s favorited article is unexpected.")
        }
    }
    
    func testInsertArticle() throws {
        // Variables
        let author = 2
        let title = "It's a new post."
        let description = "It's a description for post."
        let body = "It's a body for post."
        let tags = ["Fluent","Swift"]
        
        guard let slug = try? title.convertedToSlug() else{
            XCTFail("Generate slug is failed."); return
        }
        
        // Querying
        let article = try manager.insertArticle(author: author, title: title, slug: slug, description: description, body: body, tags: tags).wait()
        
        // Examining
        XCTAssertEqual(article.slug, slug)
        XCTAssertEqual(article.title, title)
        XCTAssertEqual(article._description, description)
        XCTAssertEqual(article.body, body)
        XCTAssertEqual(article.tagList, tags)
    }
    
    func testSelectArticleBySlug() throws {
        // Variables
        let slug = "slug_1"
        let readItUser = 3
        
        // Querying
        guard let article = try manager.selectArticles( condition: .slug(slug), readIt: readItUser).wait().first else{
            XCTFail("\(slug) is unexpected"); return
        }
        
        // Examining
        XCTAssertEqual(article.slug, slug)
        XCTAssertEqual(article.favoritesCount, 1)
        XCTAssertTrue(article.favorited)
        XCTAssertTrue(article.author.following)
        XCTAssertEqual(article.tagList.count, 1)
    }
    
    
    
    func testSelectArticleBySlugUsingFluent() throws {
        // Variables
        let slug = "slug_1"
        let readItUser = 2
        let fluent = manager.fluent
        
        // (1)Search Articles
        guard let article = try Articles.query(on: fluent)
            .filter(\.$slug == slug)
            .all()
            .wait()
            .first else{
            XCTFail(); return
        }
        
        // Load parent/childrens
        try article.$favorites.load(on: fluent)
            .flatMap{ _ in article.$author.load(on: fluent) }
            .flatMap{ _ in article.author.$follows.load(on: fluent) }
            .flatMap{ _ in article.$tags.load(on: fluent) }
            .wait()
        
        // (2)Search Tags
        let tags = article.tags
        
        // (3)Search User
        let author = article.author
        
        // (4)This article favorited?
        let favorited = article.favorites.filter{ $0.$user.id == readItUser }.isEmpty == false
        
        // (5)Author of article is followed?
        let following = article.author.follows.filter{ $0.id == readItUser }.isEmpty == false
        
        // (6)This article has number of favorite?
        let favoritesCount = article.favorites.count
        
        // Create response data
        let response = Article(slug: article.slug, title: article.title, _description: article.description, body: article.body, tagList: tags.map{ $0.tag }, createdAt: article.createdAt!, updatedAt: article.updatedAt!, favorited: favorited, favoritesCount: favoritesCount, author: Profile(username: author.username, bio: author.bio, image: author.image, following: following))
        
        // Examining
        XCTAssertEqual(response.slug, slug)
        XCTAssertEqual(response.favoritesCount, 1)
        XCTAssertFalse(response.favorited)
        XCTAssertFalse(response.author.following )
        XCTAssertEqual(response.tagList.count, 1)
    }
    
    
    func testUpdateArticleBySlug() throws {
        // Variables
        let readItUser = 1
        let slug = "slug_1"
        let title = "It's a update post."
        let description = "It's a description for update post."
        let body = "It's a body for update post."
        let tagList = ["Fluent","Vapor"]
        
        // Search Articles
        guard let article = try Articles.query(on: manager.fluent)
            .filter(\.$slug == slug)
            .all()
            .wait()
            .first else{
            XCTFail(); return
        }
        article.title = title
        article.description = description
        article.body = body
        
        // Update Article
        let _ = try article.update(on: manager.fluent).wait()
        
        // Update Tags
        try article.$tags.load(on: manager.fluent).wait()
        let tags = article.tags
        
        try tags.filter{ tagList.contains($0.tag) == false }
                .forEach{ try $0.delete(on: manager.fluent).wait() }
        try tagList.filter{ tags.map{ $0.tag }.contains($0) == false }
                .forEach{ _ = try Tags(id: nil, article: article.id!, tag: $0).save(on: manager.fluent).wait() }
                        
        // Querying
        guard let response = try manager.selectArticles(condition: .slug(slug), readIt: readItUser).wait().first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertEqual(response.slug, slug)
        XCTAssertEqual(response.title, title)
        XCTAssertEqual(response._description, description)
        XCTAssertEqual(response.body, body)
        XCTAssertEqual(response.tagList, tagList)
    }
    func testDeleteArticleBySlug() throws {
        // Variables
        let slug = "beDelete"
        
        // Querying
        try manager.deleteArticle(slug: slug).wait()
        
        // Examing
        let article = try manager.selectArticles(condition: .slug(slug)).wait().first
        XCTAssertNil(article)
    }
    
    func testSelectTags() throws {
        // Querying
        let tags = try manager.selectTags().wait()
        // Examing
        XCTAssertEqual(tags.count, 3)
        XCTAssertTrue( tags.contains("Vapor") )
        XCTAssertTrue( tags.contains("Swift") )
        XCTAssertTrue( tags.contains("Fluent") )
    }
}

