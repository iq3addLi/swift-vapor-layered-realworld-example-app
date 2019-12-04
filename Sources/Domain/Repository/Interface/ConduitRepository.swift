//
//  ConduitRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

/// Definition of the functions that the Conduit service should have.
///
/// This Repository definition does not depend on a specific storage, but depends on `SwiftNIO`.
protocol ConduitRepository: Repository {

    // MARK: Setup

    /// Prepare if necessary
    ///
    /// This name is used because initialization may not be necessary depending on the implementation.
    func ifneededPreparetion() throws

    // MARK: Users

    /// Conduit must implement input property validation.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - email: <#email description#>
    ///   - password: <#password description#>
    func validate(username: String, email: String, password: String) throws -> Future<Void>

    /// Conduit must to implement a user registration process.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - email: <#email description#>
    ///   - password: <#password description#>
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)>

    /// Conduit must to implement a user authentication process.
    /// - Parameters:
    ///   - email: <#email description#>
    ///   - password: <#password description#>
    func authUser(email: String, password: String) -> Future<(Int, User)>

    /// Conduit must to implement a user search by id.
    /// - Parameter id: <#id description#>
    /// - returns:
    ///    <#Description#>
    func searchUser(id: Int) -> Future<(Int, User)>

    /// Conduit must to implement update process for user's infomation.
    /// - Parameter id: <#id description#>
    /// - Parameter email: <#email description#>
    /// - Parameter username: <#username description#>
    /// - Parameter bio: <#bio description#>
    /// - Parameter image: <#image description#>
    /// - returns:
    ///    <#Description#>
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User>

    // MARK: Profiles

    /// Conduit must to implement search for profile.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - readingUserId: <#readingUserId description#>
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>

    /// Conduit must to implement user follow.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - userId: <#userId description#>
    func follow(followee username: String, follower userId: Int) -> Future<Profile>

    /// Conduit must to implement user unfollow.
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - userId: <#userId description#>
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>

    // MARK: Favorites

    /// Conduit must to implement favorite for article.
    /// - Parameters:
    ///   - userId: <#userId description#>
    ///   - articleSlug: <#articleSlug description#>
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>

    /// Conduit must to implement unfavorite for article.
    /// - Parameters:
    ///   - userId: <#userId description#>
    ///   - articleSlug: <#articleSlug description#>
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>

    // MARK: Comments

    /// Conduit must to implement search comment from article.
    /// - Parameter articleSlug: <#articleSlug description#>
    /// - returns:
    ///    <#Description#>
    func comments(for articleSlug: String) -> Future<[Comment]>

    /// Conduit must to implement comment to article.
    /// - Parameters:
    ///   - articleSlug: <#articleSlug description#>
    ///   - body: <#body description#>
    ///   - userId: <#userId description#>
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>

    /// Conduit must to implement uncomment to article.
    /// - Parameters:
    ///   - articleSlug: <#articleSlug description#>
    ///   - id: <#id description#>
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>

    // MARK: Articles

    /// Conduit must to implement search for articles.
    /// - Parameters:
    ///   - condition: <#condition description#>
    ///   - readingUserId: <#readingUserId description#>
    ///   - offset: <#offset description#>
    ///   - limit: <#limit description#>
    func articles( condition: ArticleCondition, readingUserId: Int?, offset: Int?, limit: Int? ) -> Future<[Article]>

    /// Conduit must to implement article post.
    /// - Parameters:
    ///   - author: <#author description#>
    ///   - title: <#title description#>
    ///   - discription: <#discription description#>
    ///   - body: <#body description#>
    ///   - tagList: <#tagList description#>
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article>

    /// Conduit must to implement article delete.
    /// - Parameter slug: <#slug description#>
    /// - returns:
    ///    <#Description#>
    func deleteArticle( slug: String ) -> Future<Void>

    /// Conduit must to implement article update.
    /// - Parameters:
    ///   - slug: <#slug description#>
    ///   - title: <#title description#>
    ///   - description: <#description description#>
    ///   - body: <#body description#>
    ///   - tagList: <#tagList description#>
    ///   - userId: <#userId description#>
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>

    // MARK: Tags

    /// Conduit must to implement tags search.
    /// - returns:
    ///    <#Description#>  
    func allTags() -> Future<[String]>
}
