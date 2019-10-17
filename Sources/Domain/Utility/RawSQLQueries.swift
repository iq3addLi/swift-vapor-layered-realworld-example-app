//
//  SQLQueryBuilder.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/17.
//


public struct RawSQLQueries{
    
    public enum ArticleCondition{
        case feed(Int) // followerId
        case favorite(String) // username
        case tag(String) // tag
        case author(String) // username
        case slug(String) // slug
    }
}

// MARK: Articles
extension RawSQLQueries{
    
    /// dummy description
    ///
    /// - note: dummy note.
    /// - warning: dummy warning
    /// - parameters:
    ///     - condition: dummy.
    ///     - userId: dummy.
    /// - returns: sql query.
    public static func selectArticles(condition: ArticleCondition, readIt userId: Int?) -> String {
        return """
        select
        Articles.id, Articles.slug, Articles.title, Articles.description, Articles.body, Articles.author, Articles.createdAt, Articles.updatedAt,
        Users.username, Users.bio, Users.image,
        (select GROUP_CONCAT(DISTINCT tag) as TagList from Tags where Tags.article = Articles.id) as tagCSV,
        ( select count(*) from Favorites where article = Articles.id ) as favoritesCount,
        \( { () -> String in
        switch userId{
        case .some( let id ): return """
            exists( select * from Follows where followee = Users.id and follower = \(id) ) as following,
            exists( select * from Favorites where article = Articles.id and user = \(id) ) as favorited
            """
        case .none: return ""
        }}() )
        \( {() -> String in
        switch condition{
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
                Favorites.user = ( select id from Users where username = "\(username)");
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
        """
    }
    
    public static func deleteArticles(slug: String) -> String {
        return """
        DELETE
            Articles, Tags, Favorites
        FROM Articles
            left join Tags on Articles.id = Tags.article
            left join Favorites on Articles.id = Favorites.article
        WHERE
            Articles.slug = "\(slug)";
        """
    }
    
    // Insert is performed by Fluent
}

// MARK: Users
extension RawSQLQueries{
    public static func selectUsers(name: String, follower id: Int?) -> String{
        return """
        select *
        \((id != nil) ? ",exists( select * from Follows where followee = Users.id and follower = \(id!) ) as following" : "" )
        from Users
        where
            username = "\(name)";
        """
    }
    
    public static func selectUsers(id userId: Int, follower id: Int?) -> String{
        return """
        select *
        \((id != nil) ? ",exists( select * from Follows where followee = Users.id and follower = \(id!) ) as following" : "" )
        from Users
        where
            id = "\(userId)";
        """
    }
    
    // Insert is performed by Fluent
}

// MARK: Comments
extension RawSQLQueries{
    
    public static func selectComments(for articleSlug: String) -> String {
        return """
        select * from Comments
        where
            article = (select id from Articles where slug = "\(articleSlug)");
        """
    }
    
    public static func insertComments(for articleSlug: String, body: String, author userId: Int ) -> String {
        return """
        insert
            into Comments (body, author, article)
        values (
            "\(body)", \(userId), (select id from Articles where slug = "\(articleSlug)")
        );
        """
    }
         
    public static func deleteComments( id: Int ) -> String {
        return """
        DELETE
        FROM Comments
        WHERE
            id = "\(id)"
        """
    }
}

// MARK: Follows
extension RawSQLQueries{
    public static func insertFollows(followee username: String, follower id: Int) -> String{
        return """
        insert
            into Follows (followee, follower)
        values (
            (select id from Users where username = "\(username)"),
            \(id)
        );
        """
    }
    
    public static func deleteFollows(followee username: String, follower id: Int) -> String{
        return """
        DELETE FROM Follows
        WHERE
            followee = (select id from Users where username = "\(username)") and
            follower = \(id);
        """
    }
}

// MARK: Favorites
extension RawSQLQueries{

    public static func insertFavorites(for articleSlug: String, by userId: Int) -> String{
        return """
        insert
            into Favorites (article, user)
        values (
            (select id from Articles where slug = "\(articleSlug)"),
            \(userId)
        );
        """
    }

    public static func deleteFavorites(for articleSlug: String, by userId: Int) -> String {
        return  """
        DELETE FROM Favorites
        WHERE
            article = (select id from Articles where slug = "\(articleSlug)") and
            user = \(userId);
        """
    }
}

// MARK: Tags
// Tag Insertion and Deletion is performed by Fluent