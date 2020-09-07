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
            _ = try manager.insertUser(name: "user_2", email: "user_2@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            
            // Test data for user relation
            let user3 = try manager.insertUser(name: "user_3", email: "user_3@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            let _ = try manager.insertFollow(followee: user1.username, follower: user3.id!).wait() // follow_user3_to_user1
            let _ = try manager.insertUser(name: "user_4", email: "user_4@realworld_test.app", hash: "dummy", salt: "dummy").wait()
            
            // Test data for articles
            let _ = try manager.insertArticle(author: user1.id!, title: "art_1", slug: "slug_1", description: "dummy", body: "dummy", tags: []).wait()
            
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
    ]
    
    func testSelectUserByEmail() throws {
        
        // Variables
        let email = "user_1@realworld_test.app"
        
        // Quering
        guard let user = try manager.selectUser(email: email).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(user.username == "user_1")
    }
    
    func testInsertUser() throws{
        // Variables
        let username = String.random(length: 8)
        let email = "\(username)@realworld_test.com"
        
        // Quering
        let user = try manager.insertUser(name: username, email: email, hash: "dummy", salt: "dummy").wait()
        
        // Examining
        XCTAssertTrue(user.id != .none)
        XCTAssertTrue(user.username == username)
    }
    
    func testSelectUserById() throws {
        // Variables
        let readItUser = 1
        
        // Quering
        guard let user = try manager.selectUser(id: readItUser).wait() else{
            XCTFail(); return
        }
        XCTAssertTrue(user.username == "user_1")
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
        XCTAssertTrue(user.username == "user_2")
        XCTAssertTrue(user.email == email)
        XCTAssertTrue(user.bio == bio)
        XCTAssertTrue(user.image == image)
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
        XCTAssertTrue(profile.username == "user_1")
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
        XCTAssertTrue(followee.username == followeeUserName)
        XCTAssertTrue(followee.following) // user_1 is follow to user_4
        XCTAssertTrue(follower.username == followerUserName)
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
    
    func testInsertFavoriteBySlug() throws {
        // Variables
        let readItUser = 2
        let favoriteArticleSlug = "slug_1"
        
        // Quering
        let article = try manager.insertFavorite(by: readItUser, for: favoriteArticleSlug).wait()
        
        // Examining
        XCTAssertTrue(article.favorited )
        XCTAssertTrue(article.favoritesCount == 1)
    }
    
    /*
    func testDeleteFavoritesByUsername() throws {
        // Variables
        let readItUser = 1
        let tergetArticleSlug = "slug_1"
    
        // Quering
        let article = try manager.deleteFavorite(by: readItUser, for: tergetArticleSlug).wait()
        
        // Examining
        XCTAssertTrue(article.favorited == false)
        XCTAssertTrue(article.favoritesCount == 0)
    }
    
    func testSelectCommentsBySlug() throws {
        // Variables
        let readItUser = 2
        let tergetArticleSlug = "slug_3"
                
        // Quering
        let comments = try manager.selectComments(for: tergetArticleSlug, readit: readItUser).wait()
        
        // Examining
        XCTAssertTrue(comments.count == 2)
        XCTAssertTrue(comments.filter{ $0.author.username == "user_1" }.first!.author.following == true)
    }
    
    func testInsertCommentBySlugUsingFluent() throws {
        // Variables
        let readItUser = 1
        let commentBody = "Comment by unittest."
        let targetArticleSlug = "slug_1"
        
        // <1>Select
        let database = manager.fluent
        guard let article = try Articles.query(on: database)
            .filter(\.$slug == targetArticleSlug)
            .all()
            .wait()
            .first else{
            XCTFail(); return
        }

        // <2>Insert to Comments
        let comment = Comments(body: commentBody, author: readItUser, article: article.id! )
        try comment
            .save(on: database)
            .wait()

        // <3>Get author infomation
        let author = comment.author
        
        // <4>Get Inserted row
        guard let row = try Comments
            .query(on: database)
            .filter(\.$id == comment.id!)
            .all()
            .wait()
            .first else{
            XCTFail(); return
        }
        
        // Create response data
        let insertedComment = Comment(_id: row.id!, createdAt: row.createdAt!, updatedAt: row.updatedAt!, body: row.body, author: Profile(username: author.username, bio: author.bio, image: author.image, following: false /* Because It's own. */))
        
        // Examining
        XCTAssertTrue(insertedComment.body == commentBody)
        XCTAssertTrue(insertedComment.author.username == author.username)
        XCTAssertTrue(row.$article.id == article.id)
    }
    
    func testDeleteCommentsBySlug() throws {
        // Variables
        let commentId = 1
        
        // Querying
        try manager.deleteComments(commentId: commentId)
            .wait()
        
        // Examining
        let rows = try Comments
            .query(on: manager.fluent)
            .all()
            .wait()
        XCTAssertTrue(rows.count == 1)
    }
    
    func testSelectArticlesbyFollower() throws {
        // Variables
        let readItUser = 2
        
        // Querying
        let articles = try manager.selectArticles(condition: .feed(readItUser), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 3)
    }
    
    func testSelectArticlesbyTag() throws {
        // Variables
        let readItUser = 2
        let tagString = "Vapor"
        
        // Querying
        let articles = try manager.selectArticles( condition: .tag(tagString), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 2)
    }
    
    func testSelectArticlesbyAuthor() throws {
        // Variables
        let readItUser = 2
        let targetUsername = "user_1"
        
        // Querying
        let articles = try manager.selectArticles(condition: .author(targetUsername), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 3)
    }
    
    func testSelectArticlesInFavorite() throws {
        // Variables
        let readItUser = 2
        let targetUsername = "user_1"
        
        // Querying
        let articles = try manager.selectArticles(condition: .favorite(targetUsername), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 1)

    }
    
    func testInsertArticle() throws {
        // Variables
        let author = 2
        let title = "It's a new post."
        let description = "It's a description for post."
        let body = "It's a body for post."
        let tags = ["NewPost","Vapor"]
        
        guard let slug = try? title.convertedToSlug() else{
            XCTFail("Generate slug is failed."); return
        }
        
        // Querying
        let article = try manager.insertArticle(author: author, title: title, slug: slug, description: description, body: body, tags: tags).wait()
        
        // Examining
        XCTAssertTrue(article.slug == slug)
        XCTAssertTrue(article.title == title)
        XCTAssertTrue(article._description == description)
        XCTAssertTrue(article.body == body)
        XCTAssertTrue(article.tagList == tags)
        
    }
    
    func testSelectArticlebySlug() throws {
        // Variables
        let slug = "slug_1"
        let readItUser = 2
        
        // Querying
        guard let article = try manager.selectArticles( condition: .slug(slug), readIt: readItUser).wait().first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(article.slug == slug)
        XCTAssertTrue(article.favoritesCount == 1)
        XCTAssertTrue(article.favorited == false)
        XCTAssertTrue(article.author.following)
        XCTAssertTrue(article.tagList.count == 0)
    }
    
    func testSelectArticlebySlugUsingFluent() throws {
        // Variables
        let slug = "slug_1"
        let readItUser = 2
        
        // (1)Search Articles
        guard let article = try Articles.query(on: manager.fluent)
            .filter(\.$slug == slug)
            .all()
            .wait()
            .first else{
            XCTFail(); return
        }
        
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
        XCTAssertTrue(response.slug == slug)
        XCTAssertTrue(response.favoritesCount == 1)
        XCTAssertTrue(response.favorited == false)
        XCTAssertTrue(response.author.following )
        XCTAssertTrue(response.tagList.count == 0)
    }
    
    func testUpdateArticlebySlug() throws {
        // Variables
        let readItUser = 1
        let slug = "slug_1"
        let title = "It's a update post."
        let description = "It's a description for update post."
        let body = "It's a body for update post."
        let tagList = ["Update","Vapor"]
        
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
        XCTAssertTrue(response.slug == slug)
        XCTAssertTrue(response.title == title)
        XCTAssertTrue(response._description == description)
        XCTAssertTrue(response.body == body)
        XCTAssertTrue(response.tagList == tagList)
    }
    
    func testDeleteArticlebySlug() throws {
        // Variables
        let slug = "slug_1"
        
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
        XCTAssertTrue(tags.count == 2)
    }
 */
}

