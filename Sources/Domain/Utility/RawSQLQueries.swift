//
//  SQLQueryBuilder.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//

/// Object that generates raw SQL.
/// I wanted to get enough information in one query.
/// The reason for using raw query is that the following function was not found in Fluent.
/// * Sub query
/// * GROUP_CONCAT(MySQL Only)
/// * Distinct
/// * DELETE JOIN
/// * exists
///
/// I may have missed it.
/// As an aside, I have never met OR-Mapper, which can cover the vast specifications of SQL.
/// This is part of the reason, I attach importance to portability over typeSafe for OR-Mapper.
/// There is also a growing need to adopt KVS. Database that interacts directly with the application.
public enum RawSQLQueries {}

// MARK: Articles
extension RawSQLQueries {
    /// Returns the query. Inquires about articles according to the argument conditions.
    /// - Parameter condition: Information that shows what criteria to search for articles.
    /// - Parameter userId: ID of the user reading this article. If nil, following is false.
    /// - Parameter offset: Search result offset. Nil is not set.
    /// - Parameter limit: Search result limit. Nil is unlimited.
    /// - returns:
    ///    SQL query string.
    public static func selectArticles(condition: ArticleCondition, readIt userId: Int?, offset: Int? = nil, limit: Int? = nil) -> String {
        return """
        select
        Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
        Users.username, Users.bio, Users.image,
        (select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
        ( select count(*) from Favorites where article = Articles.id ) as favoritesCount
        \(
        // When userId is specified
        { () -> String in
        switch userId {
        case .some( let id ): return """
            ,exists( select * from Follows where followee = Users.id and follower = \(id) ) as following,
            exists( select * from Favorites where article = Articles.id and user = \(id) ) as favorited
            """
        case .none: return ""
        }}() )
        \(
        // Switch for each search condition
        {() -> String in
        switch condition {
        case .global: return """
            from Articles
                inner join Users on Articles.author = Users.id
            """
        case .feed(let followerId): return """
            from Articles
                inner join Users on Articles.author = Users.id
                left join Follows on Articles.author = Follows.followee
            where
                Follows.follower = \(followerId)
            """
        case .favorite(let username): return """
            from Articles
                inner join Users on Users.id = Articles.author
                left join Favorites on Articles.id = Favorites.article
            where
                Favorites.user = ( select id from Users where username = "\(username)")
            """
        case .tag(let tag): return """
            from Articles
                inner join Users on Articles.author = Users.id
                left join Tags on Articles.id = Tags.article
            where
                Tags.tag = "\(tag)"
            """
        case .author(let username): return """
            from Articles
                inner join Users on Articles.author = Users.id
            where
                Users.username = "\(username)"
            """
        case .slug(let slug): return """
            from Articles
                inner join Users on Articles.author = Users.id
            where
                Articles.slug = "\(slug)"
            """
        }}() )
        \(
        // When limit is specified
        limit != nil ? "limit \(limit!)\n" : ""
        )
        \(
        // When offset is specified
        offset != nil ? "offset \(offset!)\n" : ""
        )
        """
    }

    /// Returns the query. It deletes an article and related tags and favorite information.
    /// - Parameter slug: Article's slug for delete.
    /// - returns:
    ///    SQL query string.
    public static func deleteArticles(slug: String) -> String {
        return """
        DELETE
            Articles, Tags, Favorites, Comments
        FROM Articles
            left join Tags on Articles.id = Tags.article
            left join Favorites on Articles.id = Favorites.article
            left join Comments on Articles.id = Comments.article
        WHERE
            Articles.slug = "\(slug)"
        """
    }

    // Insert is performed by SQLQueryBuilder
}

// MARK: Users
extension RawSQLQueries {

    /// Returns the query. Inquiries about users and their follow-up information.
    /// - Parameter name: Username to search for.
    /// - Parameter id: User's ID searching for the user. If nil, following is false.
    /// - returns:
    ///    SQL query string.
    public static func selectUser(name: String, follower id: Int?) -> String {
        return """
        select *
        \((id != nil) ? ",exists( select * from Follows where followee = Users.id and follower = \(id!) ) as following" : "" )
        from Users
        where
            username = "\(name)"
        """
    }

    /// Returns the query. Inquiries about users and their follow-up information.
    /// - Parameter userId: User's ID to search for.
    /// - Parameter id: User's ID searching for the user. If nil, following is false.
    /// - returns:
    ///    SQL query string.
    public static func selectUser(id userId: Int, follower id: Int?) -> String {
        return """
        select *
        \((id != nil) ? ",exists( select * from Follows where followee = Users.id and follower = \(id!) ) as following" : "" )
        from Users
        where
            id = "\(userId)"
        """
    }

    // Insert is performed by SQLQueryBuilder
}

// MARK: Comments
extension RawSQLQueries {

    /// Returns the query. Get comments associated with an article.
    /// - Parameter articleSlug: Article's slug to be commented.
    /// - Parameter userId: User who gets the comment. If nil, following is false.
    /// - returns:
    ///    SQL query string.
    public static func selectComments(for articleSlug: String, readIt userId: Int? = nil) -> String {
        return """
        select
            Comments.id, Comments.body, Comments.createdAt, Comments.updatedAt,
            Users.username, Users.email, Users.bio, Users.image
            \((userId != nil) ? ",exists( select * from Follows where followee = Users.id and follower = \(userId!) ) as following" : "" )
        from Comments
            inner join Users on Comments.author = Users.id
        where
            Comments.article = ( select id from Articles where slug = "\(articleSlug)")
        """
    }

    /// Returns the query. Inserts a comment associated with an article.
    /// - Parameter articleSlug: Article's slug to be commented.
    /// - Parameter body: A comment body.
    /// - Parameter userId: User's ID to comment.
    /// - returns:
    ///    SQL query string.
    public static func insertComments(for articleSlug: String, body: String, author userId: Int ) -> String {
        return """
        insert
            into Comments (body, author, article)
        values (
            "\(body)", \(userId), (select id from Articles where slug = "\(articleSlug)")
        )
        """
    }

    /// Returns the query. Delete the comment.
    /// - Parameter commentId: Comment ID for delete.
    /// - returns:
    ///    SQL query string.
    public static func deleteComments(id commentId: Int ) -> String {
        return """
        delete
            from Comments
        where
            id = "\(commentId)"
        """
    }

    // Insert is performed by SQLQueryBuilder
}

// MARK: Follows
extension RawSQLQueries {

    /// Returns the query. Insert follow information associated with a user.
    /// - Parameter username: Username to be followed.
    /// - Parameter id: User's Id to follow.
    /// - returns:
    ///    SQL query string.
    public static func insertFollows(followee username: String, follower id: Int) -> String {
        return """
        insert
            into Follows (followee, follower)
        values (
            (select id from Users where username = "\(username)"),
            \(id)
        )
        """
    }

    /// Returns the query. Delete follow information associated with a user.
    /// - Parameter username: Username to be unfollowed.
    /// - Parameter id: User's Id to unfollow.
    /// - returns:
    ///    SQL query string.
    public static func deleteFollows(followee username: String, follower id: Int) -> String {
        return """
        DELETE
            FROM Follows
        WHERE
            followee = (select id from Users where username = "\(username)") and
            follower = \(id)
        """
    }
}

// MARK: Favorites
extension RawSQLQueries {

    /// Returns the query. Inserts favorite information associated with an article.
    /// - Parameter articleSlug: Article's slug to be favorited.
    /// - Parameter userId: User's Id to favorite.
    /// - returns:
    ///    SQL query string.
    public static func insertFavorites(for articleSlug: String, by userId: Int) -> String {
        return """
        insert
            into Favorites (article, user)
        values (
            (select id from Articles where slug = "\(articleSlug)"),
            \(userId)
        )
        """
    }

    /// Returns the query. This deletes favorite information associated with an article.
    /// - Parameter articleSlug: Article's slug to be unfavorited.
    /// - Parameter userId: User's Id to unfavorite.
    /// - returns:
    ///    SQL query string.
    public static func deleteFavorites(for articleSlug: String, by userId: Int) -> String {
        return  """
        DELETE
            FROM Favorites
        WHERE
            article = (select id from Articles where slug = "\(articleSlug)") and
            user = \(userId)
        """
    }
}

// MARK: Tags
extension RawSQLQueries {

    /// Returns the query. It returns the tag registered in the database as unique.
    /// - returns:
    ///    SQL query string.
    public static func selectTags() -> String {
        return """
        select distinct tag from Tags
        """
    }

    // Tag Insertion and Deletion is performed by SQLQueryBuilder
}
