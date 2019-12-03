//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

/// <#Description#>
public class ArticlesUseCase: UseCase {
    private let conduit: ConduitRepository = ConduitMySQLRepository()

    /// <#Description#>
    public init() {}
    

    /// <#Description#>
    /// - parameters:
    ///     - author: <#author description#>
    ///     - feeder: <#feeder description#>
    ///     - username: <#username description#>
    ///     - tag: <#tag description#>
    ///     - offset: <#offset description#>
    ///     - limit: <#limit description#>
    ///     - readingUserId: <#readingUserId description#>
    /// - returns:
    ///    <#Description#>
    public func getArticles( author: String? = nil, feeder: Int? = nil, favorited username: String? = nil, tag: String? = nil, offset: Int? = nil, limit: Int? = nil, readingUserId: Int? = nil) -> Future<MultipleArticlesResponse> {

        let condition = { () -> ArticleCondition in
            if let feeder = feeder { return .feed(feeder) }
            if let author = author { return .author(author) }
            if let username = username { return .favorite(username) }
            if let tag = tag { return .tag(tag) }
            return .global
        }()

        // Get article from storage
        return conduit.articles(condition: condition, readingUserId: readingUserId, offset: offset, limit: limit)
            .map { articles in
            MultipleArticlesResponse(articles: articles, articlesCount: articles.count)
        }
    }

    /// <#Description#>
    /// - parameters
    ///     - slug: <#slug description#>
    ///     - readingUserId: <#readingUserId description#>
    /// - returns:
    ///    <#Description#>
    public func getArticle( slug: String, readingUserId: Int? ) -> Future<SingleArticleResponse> {
        conduit.articles(condition: .slug(slug), readingUserId: readingUserId, offset: nil, limit: nil)
            .map { articles in
                guard let article = articles.first else {
                    throw Error("Article by slug is not found.")
                }
                return SingleArticleResponse(article: article )
            }
    }

    /// <#Description#>
    /// - parameters:
    ///     - article: <#article description#>
    ///     -  userId: <#userId description#>
    /// - returns:
    ///    <#Description#>
    public func postArticle(_ article: NewArticle, author userId: Int ) -> Future<SingleArticleResponse> {
        conduit.addArticle(userId: userId, title: article.title, discription: article._description, body: article.body, tagList: article.tagList ?? [])
            .map { article in
                SingleArticleResponse(article: article )
            }
    }

    /// <#Description#>
    ///      - slug: <#slug description#>
    ///      - title: <#title description#>
    ///      - description: <#description description#>
    ///      - body: <#body description#>
    ///      - tagList: <#tagList description#>
    ///      - readingUserId: <#readingUserId description#>
    /// - returns:
    ///    <#Description#>
    public func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readingUserId: Int? ) -> Future<SingleArticleResponse> {
        conduit.updateArticle(slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: readingUserId)
            .map { article in
                SingleArticleResponse(article: article)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///     - slug: <#slug description#>
    /// - returns:
    ///    <#Description#>
    public func deleteArticle( slug: String ) -> Future<Void> {
        conduit.deleteArticle(slug: slug)
    }

    /// <#Description#>
    /// - parameters:
    ///     - userId: <#userId description#>
    ///     - articleSlug: <#articleSlug description#>
    /// - returns:
    ///    <#Description#>
    public func favorite(by userId: Int, for articleSlug: String) -> Future<SingleArticleResponse> {
        conduit.favorite(by: userId, for: articleSlug)
            .map { article in
                SingleArticleResponse(article: article)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///     - userId: <#userId description#>
    ///     - articleSlug: <#articleSlug description#>
    /// - returns:
    ///    <#Description#>
    public func unfavorite(by userId: Int, for articleSlug: String) -> Future<SingleArticleResponse> {
        conduit.unfavorite(by: userId, for: articleSlug)
            .map { article in
                SingleArticleResponse(article: article)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///      - slug: <#slug description#>
    /// - returns:
    ///    <#Description#>
    public func getComments( slug: String ) -> Future<MultipleCommentsResponse> {
        conduit.comments(for: slug)
            .map { comments in
                MultipleCommentsResponse(comments: comments)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///      - slug: <#slug description#>
    ///      - body: <#body description#>
    ///      - author: <#author description#>
    /// - returns:
    ///    <#Description#>
    public func postComment( slug: String, body: String, author: Int ) -> Future<SingleCommentResponse> {
        conduit.addComment(for: slug, body: body, author: author)
            .map { comment in
                SingleCommentResponse(comment: comment)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///      - slug: <#slug description#>
    ///      - id: <#id description#>
    /// - returns:
    ///    <#Description#> 
    public func deleteComment( slug: String, id: Int ) -> Future<Void> {
        conduit.deleteComment( for: slug, id: id)
    }
}
