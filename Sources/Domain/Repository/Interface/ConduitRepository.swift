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

    /// Prepare if necessary.
    ///
    /// This name is used because initialization may not be necessary depending on the implementation.
    /// - throws:
    ///    This function is expected to throw an error in some process related to initialization.
    func ifneededPreparetion() throws
/*
    // MARK: Users

    /// Conduit must implement input property validation.
    /// - Parameters:
    ///   - username: It's a property to be verified.
    ///   - email: It's a property to be verified.
    ///   - password: It's a property to be verified.
    /// - throws:
    ///    This function is expected to throw an error in some process related to validation.
    /// - returns:
    ///    The `Future` where implementation will be implemented.
    func validate(username: String, email: String, password: String) throws -> Future<Void>

    /// Conduit must to implement a user registration process.
    /// - Parameters:
    ///   - username: Request the name of the user to use in the service.
    ///   - email: Request email for use within the service.
    ///   - password: Requests the password that the registrant uses in the service.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Since `User` in Swagger Spec does not contain id, it is expected to return separately.
    func registerUser(name username: String, email: String, password: String) -> Future<(Int, User)>

    /// Conduit must to implement a user authentication process.
    /// - Parameters:
    ///   - email: Used to identify the user.
    ///   - password: Used for authentication.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Since `User` in Swagger Spec does not contain id, it is expected to return separately.
    func authUser(email: String, password: String) -> Future<(Int, User)>

    /// Conduit must to implement a user search by id.
    /// - Parameter id: Used to identify the user.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Since `User` in Swagger Spec does not contain id, it is expected to return separately.
    func searchUser(id: Int) -> Future<(Int, User)>

    /// Conduit must to implement update process for user's infomation.
    /// - Parameter id: Used to identify the user.
    /// - Parameter email: The updated email. Nil means unspecified.
    /// - Parameter username: The updated username. Nil means unspecified.
    /// - Parameter bio: The updated bio. Nil means unspecified.
    /// - Parameter image: The updated image. Nil means unspecified.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `User` after being updated.
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> Future<User>

    // MARK: Profiles

    /// Conduit must to implement search for profile.
    /// - Parameters:
    ///   - username: Used to identify the user.
    ///   - readingUserId: User's Id that referenced Profile.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Profile` as search result.
    func searchProfile(username: String, readingUserId: Int?) -> Future<Profile>

    /// Conduit must to implement user follow.
    /// - Parameters:
    ///   - username: Followee's user name.
    ///   - userId: Follower's user Id.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Profile` after being followed.
    func follow(followee username: String, follower userId: Int) -> Future<Profile>

    /// Conduit must to implement user unfollow.
    /// - Parameters:
    ///   - username: Followee's user name.
    ///   - userId: Follower's user Id.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Profile` after being unfollowed.
    func unfollow(followee username: String, follower userId: Int) -> Future<Profile>

    // MARK: Favorites

    /// Conduit must to implement favorite for article.
    /// - Parameters:
    ///   - userId: Favorite user id.
    ///   - articleSlug: Slug of favorite article.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Profile` after the favorites are added.
    func favorite(by userId: Int, for articleSlug: String) -> Future<Article>

    /// Conduit must to implement unfavorite for article.
    /// - Parameters:
    ///   - userId: Favorite user name.
    ///   - articleSlug: Slug of favorite article.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Profile` after the favorites are removed.
    func unfavorite(by userId: Int, for articleSlug: String) -> Future<Article>

    // MARK: Comments

    /// Conduit must to implement search comment from article.
    /// - Parameter articleSlug: Slug of the article to comment.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `[Comment]` as search result.
    func comments(for articleSlug: String) -> Future<[Comment]>

    /// Conduit must to implement comment to article.
    /// - Parameters:
    ///   - articleSlug: Slug of the article to comment.
    ///   - body: Body of comment.
    ///   - userId: Id of comment author.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `User` after being added.
    func addComment(for articleSlug: String, body: String, author userId: Int) -> Future<Comment>

    /// Conduit must to implement uncomment to article.
    /// - Parameters:
    ///   - articleSlug: Slug of the article to comment.
    ///   - id: Id of comment to remove.
    /// - returns:
    ///    The `Future` where implementation will be implemented.
    func deleteComment(for articleSlug: String, id: Int) -> Future<Void>

    // MARK: Articles

    /// Conduit must to implement search for articles.
    /// - Parameters:
    ///   - condition: Condition used to search for articles.
    ///   - readingUserId: Subject user id. If nil, follow contains invalid information.
    ///   - offset: Offset to search results. nil means unspecified.
    ///   - limit: Limit to search results. nil means unspecified.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `[Article]` as search result.
    func articles( condition: ArticleCondition, readingUserId: Int?, offset: Int?, limit: Int? ) -> Future<[Article]>

    /// Conduit must to implement article post.
    /// - Parameters:
    ///   - author: Id of the new article author.
    ///   - title: Title of the new article.
    ///   - discription: Description of the new article.
    ///   - body: Body of the new article.
    ///   - tagList: Array of tag strings attached to new article.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Article` after being added.
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Future<Article>

    /// Conduit must to implement article delete.
    /// - Parameter slug: Slug of article to be deleted.
    /// - returns:
    ///    The `Future` where implementation will be implemented.
    func deleteArticle( slug: String ) -> Future<Void>

    /// Conduit must to implement article update.
    /// - Parameters:
    ///   - slug: Slug of article to be updated.
    ///   - title: Title of article to be updated, nil means unspecified.
    ///   - description: Description of article to be updated, nil means unspecified.
    ///   - body: Body of article to be updated, nil means unspecified.
    ///   - tagList: Array of tag strings attached to be updated article, nil means unspecified.
    ///   - userId: Subject user id. If nil, follow contains invalid information.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `Article` after being updated.
    func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readIt userId: Int?) -> Future<Article>
*/
    // MARK: Tags

    /// Conduit must to implement tags search.
    /// - returns:
    ///    The `Future` where implementation will be implemented. Expected to return a `[String]` as search result.
    func allTags() -> Future<[String]>
}
