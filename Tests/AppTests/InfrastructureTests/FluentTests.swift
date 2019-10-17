//
//  FluentTests.swift
//  AppTests
//
//  Created by iq3AddLi on 2019/10/08.
//

import XCTest
import FluentMySQL

import Domain
import Infrastructure
import SwiftSlug

final class MySQLFluentTests: XCTestCase {
    
    lazy var manager: MySQLDatabaseManager! = {
        return MySQLDatabaseManager()
    }()
    
    lazy var connection: MySQLConnection! = {
        do {
            return try self.manager.newConnection()
        }catch( let error ){
            fatalError(error.localizedDescription)
        }
    }()
    
    deinit{
        connection.close()
        manager = nil
    }
    
    static let allTests = [
        ("testSelectUserByEmail", testSelectUserByEmail),
        ("testInsertUser", testInsertUser),
    ]
    
    func testSelectUserByEmail() throws {
        // Variables
        let email = "user_1@realworld_test.app"
        
        // <1>Select
        guard let row = try Users.query(on: connection).decode(data: UserWithFollowRow.self).filter(\Users.email == email).all().wait().first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(row.username == "user_1")
    }
    
    func testInsertUser() throws{
        // Variables
        let username = randomString(length: 8)
        let email = "\(username)@realworld_test.com"
        let hash = "hash_salt"
        let salt = "_salt"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Insert row
        let user = try Users(id: nil, username: username, email: email, hash: hash, salt: salt).save(on: connection).wait()
        
        // Examining
        XCTAssertTrue(user.id != .none)
        XCTAssertTrue(user.username == username)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectUserById() throws {
        // Variables
        let ownUserId = 1
        
        guard let row = try Users.query(on: connection).decode(data: UserWithFollowRow.self).filter(\Users.id == ownUserId).all().wait().first else{
            XCTFail(); return
        }
        XCTAssertTrue(row.username == "user_1")
    }
    
    func testUpdateUser() throws {
        // Variables
        let ownUserId = 1
        
        // Find user
        guard let row = try Users.query(on: connection).filter(\Users.id == ownUserId).all().wait().first else{
            XCTFail(); return
        }
        row.email = "updated"
        row.bio   = "updated"
        row.image = "updated"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Update row
        let updatedUser = try row.update(on: connection ).wait()
        
        // Examining
        XCTAssertTrue(updatedUser.email == "updated")
        XCTAssertTrue(updatedUser.bio == "updated")
        XCTAssertTrue(updatedUser.image == "updated")
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectProfileByUsername() throws {
        // Variables
        let ownUserId = 2
        let tergetUserName = "user_1"
        
        // <1>Select
        let rows = try connection.raw( SQLQueryBuilder.selectUsers(name: tergetUserName, follower: ownUserId) )
            .all(decoding: UserWithFollowRow.self )
            .wait()
        
        guard let user = rows.first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(user.id == 1)
        XCTAssertTrue(user.username == "user_1")
        XCTAssertTrue(user.following ?? false)
    }
    
    func testInsertFollowsByUsername() throws {
        // Variables
        let ownUserId = 1
        let tergetUserName = "user_2"
                
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Update
        _ = try connection.raw( SQLQueryBuilder.insertFollows(followee: tergetUserName, follower: ownUserId) ).all().wait()
        
        // <2>Select
        let rows = try connection.raw( SQLQueryBuilder.selectUsers(name: tergetUserName, follower: ownUserId) ).all(decoding: UserWithFollowRow.self).wait()
        guard let user = rows.first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(user.following ?? false)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testInsertFollowsByUsernameUsingFluent() throws {
        // Variables
        let ownUserId = 1
        let tergetUserName = "user_2"
    
        // <1>Select
        guard let followee = try Users.query(on: connection).decode(data: UserWithFollowRow.self).filter(\Users.username == tergetUserName).all().wait().first else{
            XCTFail(); return
        }
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <2>Insert to Follows
        let follow = try Follows(id: nil, followee: followee.id, follower: ownUserId).save(on: connection).wait()
        
        // Create response data
        let profile = UserWithFollowRow(id: followee.id, username: followee.username, email: followee.email, bio: followee.bio, image: followee.image, following: follow.followee == followee.id ) // Because it's insert
        
        // Examining
        XCTAssertTrue(profile.following ?? false)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testDeleteFollowsByUsername() throws {
        // Variables
        let ownUserId = 2
        let tergetUserName = "user_1"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Update
        _ = try connection.raw( SQLQueryBuilder.deleteFollows(followee: tergetUserName, follower: ownUserId) ).all().wait()
        
        // <2>Select
        let rows = try connection.raw( SQLQueryBuilder.selectUsers(name: tergetUserName, follower: ownUserId) ).all(decoding: UserWithFollowRow.self).wait()
        guard let user = rows.first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(user.following ?? false == false)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testInsertFavoriteBySlug() throws {
        // Variables
        let ownUserId = 2
        let tergetArticleSlug = "slug_3"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Insert
        _ = try connection.raw( SQLQueryBuilder.insertFavorites(for: tergetArticleSlug, by: ownUserId ) ).all().wait()
        
        // <2>Select
        let rows = try connection.raw( SQLQueryBuilder.selectArticles(condition: .slug(tergetArticleSlug), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        guard let article = rows.first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(article.favorited ?? false )
        XCTAssertTrue(article.favoritesCount == 1)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testDeleteFavoritesByUsername() throws {
        // Variables
        let ownUserId = 1
        let tergetArticleSlug = "slug_1"
    
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Update
        _ = try connection.raw( SQLQueryBuilder.deleteFavorites(for: tergetArticleSlug, by: ownUserId ) ).all().wait()
        
        // <2>Select
        let rows = try connection.raw( SQLQueryBuilder.selectArticles(condition: .slug(tergetArticleSlug), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        guard let article = rows.first else{
            XCTFail(); return
        }
        
        // Examining
        XCTAssertTrue(article.favorited ?? false == false)
        XCTAssertTrue(article.favoritesCount == 0)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectCommentsBySlug() throws {
        // Variables
        let ownUserId = 2
        let tergetArticleSlug = "slug_3"
                
        // <1>Select
        let rows = try connection.raw( SQLQueryBuilder.selectComments(for: tergetArticleSlug) ).all(decoding: Comments.self).wait()

        // Select profile in comments
        let comments = try rows.map { (comment: Comments) -> Comment in
            
            // <2>Select
            let rows = try connection.raw( SQLQueryBuilder.selectUsers(id: comment.author, follower: ownUserId) ).all(decoding: UserWithFollowRow.self).wait()
            guard let user = rows.first else{
                XCTFail(); fatalError()
            }
            
            return Comment(_id: comment.id!, createdAt: comment.createdAt!, updatedAt: comment.updatedAt!, body: comment.body, author: Profile(username: user.username, bio: user.bio, image: user.image, following: user.following ?? false))
        }
        
        // Examining
        XCTAssertTrue(comments.count == 2)
        XCTAssertTrue(comments.filter{ $0.author.username == "user_1" }.first!.author.following == true)
        
    }
    
    func testInsertCommentBySlug() throws {
        
        // Variables
        let ownUserId = 1
        let commentBody = "Comment by unittest."
        let targetArticleSlug = "slug_1"
        
        // Raw queries
        let selectNextIdQueryString = """
SELECT auto_increment FROM information_schema.tables WHERE table_name = "\(Comments.name)";
"""
        
        // <1>Select next id
        guard let nextId = try connection.raw( selectNextIdQueryString ).all(decoding: NextIdRow.self).wait().first else{
            XCTFail(); return
        }
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <2>Insert comment
        _ = try connection.raw( SQLQueryBuilder.insertComments(for: targetArticleSlug, body: commentBody, author: ownUserId ) ).all().wait()
        
        // <3>Select comment
        guard let comment = try Comments.query(on: connection).filter(\Comments.id == nextId.auto_increment).all().wait().first else{
            XCTFail(); return
        }
        
        // <4>Get author infomation
        guard let author = try comment.commentedUser?.get(on: connection).wait() else{
            XCTFail(); return
        }
        
        // Create response data
        let insertedComment = Comment(_id: comment.id!, createdAt: comment.createdAt!, updatedAt: comment.updatedAt!, body: comment.body, author: Profile(username: author.username, bio: author.bio, image: author.image, following: false /* Because It's own. */))
        
        // Examining
        XCTAssertTrue(insertedComment._id == nextId.auto_increment)
        XCTAssertTrue(insertedComment.body == commentBody)
        XCTAssertTrue(insertedComment.author.username == author.username)
        XCTAssertTrue(comment.article == 1)
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testInsertCommentBySlugUsingFluent() throws {
        // Variables
        let ownUserId = 1
        let commentBody = "Comment by unittest."
        let targetArticleSlug = "slug_1"
        
        // <1>Select
        guard let article = try Articles.query(on: connection).filter(\Articles.slug == targetArticleSlug).all().wait().first else{
            XCTFail(); return
        }

        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <2>Insert to Comments
        let inserted = try Comments(body: commentBody, author: ownUserId, article: article.id! ).save(on: connection).wait() // MEMO: Return value's timestamp is nil when insert😣 So need to select again😩

        // <3>Get author infomation
        guard let author = try inserted.commentedUser?.get(on: connection).wait() else{
            XCTFail(); return
        }
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
        
        // <1>Delete comment
        _ = try connection.raw( SQLQueryBuilder.deleteComments( id: commentId ) ).all().wait().first
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectArticlesbyFollower() throws {
        // Variables
        let ownUserId = 2
        
        // Raw query
//        let selectArticlesQueryString = """
//select
//    Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
//    Users.username, Users.bio, Users.image,
//    (select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
//    exists( select * from Follows where followee = Users.id and follower = \(ownUserId) ) as following,
//    exists( select * from Favorites where article = Articles.id and user = Follows.follower ) as favorited,
//    ( select count(*) from Favorites where article = Articles.id ) as favoritesCount
//from Articles
//    inner join Users on Articles.author = Users.id
//    left join Follows on Articles.author = Follows.followee
//where
//    Follows.follower = \(ownUserId);
//"""
        
        // <1>Select article
        let rows = try connection.raw( SQLQueryBuilder.selectArticles(condition: .feed(ownUserId), readIt: ownUserId)  ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        
        // Create response data
        let articles = rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
        
        // Examining
        XCTAssertTrue(articles.count == 3)
    }
    
    func testSelectArticlesbyTag() throws {
        // Variables
        let ownUserId = 2
        let tagString = "Vapor"
        
        // Raw query
//        let selectArticlesQueryString = """
//select
//    Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
//    exists( select * from Favorites where article = Articles.id and user = \(ownUserId) ) as favorited,
//    ( select count(*) from Favorites where article = Articles.id ) as favoritesCount,
//    (select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
//    Users.username, Users.bio, Users.image,
//    exists( select * from Follows where followee = Users.id and follower = \(ownUserId) ) as following
//from Articles
//    inner join Users on Articles.author = Users.id
//    left join Tags on Articles.id = Tags.article
//where
//    Tags.tag = "\(tagString)";
//"""
        
        // <1>Select article
        let rows = try connection.raw( SQLQueryBuilder.selectArticles(condition: .tag(tagString), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        
        // Create response data
        let articles = rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
        
        // Examining
        XCTAssertTrue(articles.count == 2)
    }
    
    func testSelectArticlesbyAuthor() throws {
        // Variables
        let ownUserId = 2
        let targetUsername = "user_1"
        
        // Raw query
//        let selectArticlesQueryString = """
//select
//    Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
//    exists( select * from Favorites where article = Articles.id and user = \(ownUserId) ) as favorited,
//    ( select count(*) from Favorites where article = Articles.id ) as favoritesCount,
//    (select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
//    Users.username, Users.bio, Users.image,
//    exists( select * from Follows where followee = Users.id and follower = \(ownUserId) ) as following
//from Articles
//    inner join Users on Articles.author = Users.id
//where
//    Users.username = "\(targetUsername)";
//"""
        
        // <1>Select article
        let rows = try connection.raw( SQLQueryBuilder.selectArticles(condition: .author(targetUsername), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        
        // Create response data
        let articles = rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
        
        // Examining
        XCTAssertTrue(articles.count == 3)
    }
    
    func testSelectArticlesInFavorite() throws {
        // Variables
        let ownUserId = 2
        let targetUsername = "user_1"
        
        // Raw query
//        let selectArticlesQueryString = """
//select
//    Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
//    exists( select * from Favorites where article = Articles.id and user = ( select id from Users where username = "\(targetUsername)") ) as favorited,
//    ( select count(*) from Favorites where article = Articles.id ) as favoritesCount,
//    ( select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
//    Users.username, Users.bio, Users.image,
//    exists( select * from Follows where followee = Users.id and follower = \(ownUserId) ) as following
//from Articles
//    inner join Users on Users.id = Articles.author
//    left join Favorites on Articles.id = Favorites.article
//where
//    Favorites.user = ( select id from Users where username = "\(targetUsername)");
//"""
        
        // <1>Select article
        let rows = try connection.raw( SQLQueryBuilder.selectArticles(condition: .favorite(targetUsername), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait()
        
        // Create response data
        let articles = rows.map{ row in
            Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        }
        
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
        
        // Set new article
        let article = try Articles(id: nil, slug: slug + randomString(length: 36), title: title, description: description, body: body, author: author).save(on: connection).wait()
        
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: tags.count)
        
        // Set new tags
        let orders = tags.map{ Tags(id: nil, article: article.id!, tag: $0 ).save(on: connection) }
        
        // Bundle future (Perhaps this is not valid)
        let future = EventLoopFuture.reduce(0, orders, eventLoop: evGroup.next()) { (count: Int, tag: Tags) in
            // Examining
            XCTAssertNotNil( tag.id )
            return count
        }
        future.whenSuccess { (count) in
            print("Success")
        }
        future.whenFailure { error in
            print("Failed result=\(error)")
        }
        
        _ = try future.wait()
        
        // Collect eventLoopGroup
        try evGroup.syncShutdownGracefully()
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
    func testSelectArticlebySlug() throws {
        // Variables
        let slug = "slug_1"
        let ownUserId = 2
        
        // Raw query
//        let selectArticlesQueryString = """
//select
//    Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
//    exists( select * from Favorites where article = Articles.id and user = \(ownUserId)) as favorited,
//    ( select count(*) from Favorites where article = Articles.id ) as favoritesCount,
//    ( select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
//    Users.username, Users.bio, Users.image,
//    exists( select * from Follows where followee = Users.id and follower = \(ownUserId) ) as following
//from Articles
//    inner join Users on Articles.author = Users.id
//    left join Favorites on Articles.id = Favorites.article
//where
//    Articles.slug = "\(slug)"
//"""
        
        // <1>Select article
        guard let row = try connection.raw( SQLQueryBuilder.selectArticles(condition: .slug(slug), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait().first else{
            XCTFail(); return
        }
        
        // Create response data
        let response = Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        
        // Examining
        XCTAssertTrue(response.slug == slug)
        XCTAssertTrue(response.favoritesCount == 1)
        XCTAssertTrue(response.favorited == false)
        XCTAssertTrue(response.author.following)
        XCTAssertTrue(response.tagList.count == 0)
    }
    
    func testSelectArticlebySlugUsingFluent() throws {
        // Variables
        let slug = "slug_1"
        let ownUserId = 2
        
        // Search Articles
        guard let article = try Articles.query(on: connection).filter(\Articles.slug == slug).all().wait().first else{
            XCTFail(); return
        }
        
        // Search Tags
        let tags = try article.tags.query(on: connection).all().wait()
        
        // Search User
        guard let author = try article.postedUser?.get(on: connection).wait() else{
            XCTFail(); return
        }
        
        // This article favorited?
        let favorited = try Favorites.query(on: connection).filter(\Favorites.user == ownUserId).filter(\Favorites.article == article.id!).all().wait().count != 0
        
        // Author of article is followed?
        let following = try Follows.query(on: connection).filter(\Follows.follower == ownUserId).filter(\Follows.followee == article.author).all().wait().count != 0
        
        // This article has number of favorite?
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
        let ownUserId = 1
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
        
        // Allow dirty reads
        //_ = try! connection.simpleQuery("SET SESSION TRANSACTION ISOLATION LEVEL read uncommitted").wait()
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        

        // Update Article
        let _ = try article.update(on: connection).wait()
        
        // Search Tags
        let tags = try article.tags.query(on: connection).all().wait()
        
        try tags.filter{ tagList.contains($0.tag) == false }
            .forEach{
                try $0.delete(on: connection).wait()
        }
        try tagList.filter{ tags.map{ $0.tag }.contains($0) == false }
            .forEach{
                _ = try Tags(id: nil, article: article.id!, tag: $0).save(on: connection).wait()
        }
        
//        // Raw query
//        let selectArticlesQueryString = """
//select
//    Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
//    exists( select * from Favorites where article = Articles.id and user = \(ownUserId)) as favorited,
//    ( select count(*) from Favorites where article = Articles.id ) as favoritesCount,
//    ( select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
//    Users.username, Users.bio, Users.image,
//    exists( select * from Follows where followee = Users.id and follower = \(ownUserId) ) as following
//from Articles
//    inner join Users on Articles.author = Users.id
//    left join Favorites on Articles.id = Favorites.article
//where
//    Articles.slug = "\(slug)"
//"""
                
        // <1>Select article
        guard let row = try connection.raw( SQLQueryBuilder.selectArticles(condition: .slug(slug), readIt: ownUserId) ).all(decoding: ArticlesAndAuthorWithFavoritedRow.self).wait().first else{
            XCTFail(); return
        }
        
        // Create response data
        let response = Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: row.tagCSV?.components(separatedBy: ",") ?? [], createdAt: row.createdAt, updatedAt: row.updatedAt, favorited: row.favorited ?? false, favoritesCount: row.favoritesCount, author: Profile(username: row.username, bio: row.bio, image: row.image, following: row.following ?? false))
        
        // Examining
        XCTAssertTrue(response.slug == slug)
        XCTAssertTrue(response.title == title)
        XCTAssertTrue(response._description == description)
        XCTAssertTrue(response.body == body)
        XCTAssertTrue(response.tagList == tagList)
        
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
        
        // Restore transaction level
        //_ = try! connection.simpleQuery("SET SESSION TRANSACTION ISOLATION LEVEL read uncommitted").wait()
        
    }
    
    func testDeleteArticlebySlug() throws {
        // Variables
        let slug = "slug_1"
        
        // transaction start
        _ = try! connection.simpleQuery("START TRANSACTION").wait()
        
        // <1>Delete tables
        _ = try connection.raw( SQLQueryBuilder.deleteArticles(slug: slug) ).all().wait()
        
        // transaction rollback
        _ = try! connection.simpleQuery("ROLLBACK").wait()
    }
    
}


private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
