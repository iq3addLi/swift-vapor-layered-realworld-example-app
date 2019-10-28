//
//  FluentTests.swift
//  AppTests
//
//  Created by iq3AddLi on 2019/10/08.
//

import XCTest
import FluentMySQL

@testable import Domain
import Infrastructure
import SwiftSlug

final class MySQLFluentTests: XCTestCase {
    
    lazy var manager: MySQLDatabaseManager! = {
        return MySQLDatabaseManager()
    }()
    
    // Note: Naturally, transactions work within the same connection.
    lazy var connection: MySQLConnection! = {
        do {
            return try self.manager.newConnection(on: worker).wait()
        }catch( let error ){
            fatalError(error.localizedDescription)
        }
    }()
    
    private lazy var worker: Worker = {
        MultiThreadedEventLoopGroup(numberOfThreads: 2)
    }()
    
    /// dummy comment
    deinit{
        connection.close()
        
        worker.shutdownGracefully{ (error) in
            if let error = error{
                print("Worker shutdown is failed. reason=\(error)")
            }
        }
        manager = nil
    }
    
    static let allTests = [
        ("testSelectUserByEmail", testSelectUserByEmail),
        ("testInsertUser", testInsertUser),
    ]
    
    func testSelectUserByEmail() throws {
        // Variables
        let email = "user_1@realworld_test.app"
        
        // Quering
        guard let user = try manager.selectUser(on: connection, email: email).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(user.username == "user_1")
    }
    
    func testInsertUser() throws{
        // Variables
        let username = randomString(length: 8)
        let email = "\(username)@realworld_test.com"
        let hash = "hash_salt"
        let salt = "_salt"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Quering
        let user = try manager.insertUser(on: connection, name: username, email: email, hash: hash, salt: salt).wait()
        
        // Examining
        XCTAssertTrue(user.id != .none)
        XCTAssertTrue(user.username == username)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectUserById() throws {
        // Variables
        let readItUser = 1
        
        // Quering
        guard let user = try manager.selectUser(on: connection, id: readItUser).wait() else{
            XCTFail(); return
        }
        XCTAssertTrue(user.username == "user_1")
    }
    
    func testUpdateUser() throws {
        // Variables
        let readItUser = 1
        let email = "updated"
        let bio   = "updated"
        let image = "updated"

        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Quering
        let user = try manager.updateUser(on: connection, id: readItUser, email: email, bio: bio, image: image).wait()
        
        // Examining
        XCTAssertTrue(user.email == "updated")
        XCTAssertTrue(user.bio == "updated")
        XCTAssertTrue(user.image == "updated")
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectProfileByUsername() throws {
        // Variables
        let readItUser = 2
        let tergetUserName = "user_1"
        
        // Quering
        guard let profile = try manager.selectProfile(on: connection, username: tergetUserName, readIt: readItUser).wait() else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(profile.username == "user_1")
        XCTAssertTrue(profile.following )
    }
    
    func testInsertFollowsByUsername() throws {
        // Variables
        let readItUser = 1
        let tergetUserName = "user_2"
                
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Quering
        let profile = try manager.insertFollow(on: connection, followee: tergetUserName, follower: readItUser).wait()
        
        // Examining
        XCTAssertTrue(profile.following)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }

    
    func testDeleteFollowsByUsername() throws {
        // Variables
        let readItUser = 2
        let tergetUserName = "user_1"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Quering
        let profile = try manager.deleteFollow(on: connection, followee: tergetUserName, follower: readItUser).wait()
        
        // Examining
        XCTAssertTrue(profile.following == false)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testInsertFavoriteBySlug() throws {
        // Variables
        let readItUser = 2
        let tergetArticleSlug = "slug_3"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Quering
        let article = try manager.insertFavorite(on: connection, by: readItUser, for: tergetArticleSlug).wait()
        
        // Examining
        XCTAssertTrue(article.favorited )
        XCTAssertTrue(article.favoritesCount == 1)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testDeleteFavoritesByUsername() throws {
        // Variables
        let readItUser = 1
        let tergetArticleSlug = "slug_1"
    
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Quering
        let article = try manager.deleteFavorite(on: connection, by: readItUser, for: tergetArticleSlug).wait()
        
        // Examining
        XCTAssertTrue(article.favorited == false)
        XCTAssertTrue(article.favoritesCount == 0)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectCommentsBySlug() throws {
        // Variables
        let readItUser = 2
        let tergetArticleSlug = "slug_3"
                
        // Quering
        let comments = try manager.selectComments(on: connection, for: tergetArticleSlug, readit: readItUser).wait()
        
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
        guard let article = try Articles.query(on: connection).filter(\Articles.slug == targetArticleSlug).all().wait().first else{
            XCTFail(); return
        }

        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <2>Insert to Comments
        let inserted = try Comments(body: commentBody, author: readItUser, article: article.id! ).save(on: connection).wait() // MEMO: Return value's timestamp is nil when insert😣 So need to select again😩

        // <3>Get author infomation
        let author = try inserted.commentedUser.get(on: connection).wait()
        
        // <4>Get Inserted row
        guard let row = try Comments.query(on: connection).filter(\Comments.id == inserted.id!).all().wait().first else{
            XCTFail(); return
        }
        
        // Create response data
        let insertedComment = Comment(_id: row.id!, createdAt: row.createdAt!, updatedAt: row.updatedAt!, body: row.body, author: Profile(username: author.username, bio: author.bio, image: author.image, following: false /* Because It's own. */))
        
        // Examining
        XCTAssertTrue(insertedComment.body == commentBody)
        XCTAssertTrue(insertedComment.author.username == author.username)
        XCTAssertTrue(row.article == article.id)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testDeleteCommentsBySlug() throws {
        // Variables
        let commentId = 1
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Querying
        try manager.deleteComments(on: connection, commentId: commentId).wait()
        
        // Examining
        let rows = try Comments.query(on: connection).all().wait()
        XCTAssertTrue(rows.count == 1)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectArticlesbyFollower() throws {
        // Variables
        let readItUser = 2
        
        // Querying
        let articles = try manager.selectArticles(on: connection, condition: .feed(readItUser), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 3)
    }
    
    func testSelectArticlesbyTag() throws {
        // Variables
        let readItUser = 2
        let tagString = "Vapor"
        
        // Querying
        let articles = try manager.selectArticles(on: connection, condition: .tag(tagString), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 2)
    }
    
    func testSelectArticlesbyAuthor() throws {
        // Variables
        let readItUser = 2
        let targetUsername = "user_1"
        
        // Querying
        let articles = try manager.selectArticles(on: connection, condition: .author(targetUsername), readIt: readItUser).wait()
        
        // Examining
        XCTAssertTrue(articles.count == 3)
    }
    
    func testSelectArticlesInFavorite() throws {
        // Variables
        let readItUser = 2
        let targetUsername = "user_1"
        
        // Querying
        let articles = try manager.selectArticles(on: connection, condition: .favorite(targetUsername), readIt: readItUser).wait()
        
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
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Querying
        let article = try manager.insertArticle(on: connection, author: author, title: title, slug: slug, description: description, body: body, tags: tags).wait()
        
        // Examining
        XCTAssertTrue(article.slug == slug)
        XCTAssertTrue(article.title == title)
        XCTAssertTrue(article._description == description)
        XCTAssertTrue(article.body == body)
        XCTAssertTrue(article.tagList == tags)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectArticlebySlug() throws {
        // Variables
        let slug = "slug_1"
        let readItUser = 2
        
        // Querying
        guard let article = try manager.selectArticles(on: connection, condition: .slug(slug), readIt: readItUser).wait().first else{
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
        guard let article = try Articles.query(on: connection).filter(\Articles.slug == slug).all().wait().first else{
            XCTFail(); return
        }
        
        // (2)Search Tags
        let tags = try article.tags.query(on: connection).all().wait()
        
        // (3)Search User
        guard let author = try article.postedUser?.get(on: connection).wait() else{
            XCTFail(); return
        }
        
        // (4)This article favorited?
        let favorited = try Favorites.query(on: connection).filter(\Favorites.user == readItUser).filter(\Favorites.article == article.id!).all().wait().count != 0
        
        // (5)Author of article is followed?
        let following = try Follows.query(on: connection).filter(\Follows.follower == readItUser).filter(\Follows.followee == article.author).all().wait().count != 0
        
        // (6)This article has number of favorite?
        let favoritesCount = try Favorites.query(on: connection).filter(\Favorites.article == article.id!).all().wait().count
               
        
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
        guard let article = try Articles.query(on: connection).filter(\Articles.slug == slug).all().wait().first else{
            XCTFail(); return
        }
        article.title = title
        article.description = description
        article.body = body
                
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()

        // Update Article
        let _ = try article.update(on: connection).wait()
        
        // Update Tags
        let tags = try article.tags.query(on: connection).all().wait()
        
        try tags.filter{ tagList.contains($0.tag) == false }
                .forEach{ try $0.delete(on: connection).wait() }
        try tagList.filter{ tags.map{ $0.tag }.contains($0) == false }
                .forEach{ _ = try Tags(id: nil, article: article.id!, tag: $0).save(on: connection).wait() }
                        
        // Querying
        guard let response = try manager.selectArticles(on: connection, condition: .slug(slug), readIt: readItUser).wait().first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(response.slug == slug)
        XCTAssertTrue(response.title == title)
        XCTAssertTrue(response._description == description)
        XCTAssertTrue(response.body == body)
        XCTAssertTrue(response.tagList == tagList)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
        
    }
    
    func testDeleteArticlebySlug() throws {
        // Variables
        let slug = "slug_1"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // Querying
        try manager.deleteArticle(on: connection, slug: slug).wait()
        
        // Examing
        let article = try manager.selectArticles(on: connection, condition: .slug(slug)).wait().first
        XCTAssertNil(article)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectTags() throws {
        // Querying
        let tags = try manager.selectTags(on: connection).wait()
        // Examing
        XCTAssertTrue(tags.count == 2)
    }
}


private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
