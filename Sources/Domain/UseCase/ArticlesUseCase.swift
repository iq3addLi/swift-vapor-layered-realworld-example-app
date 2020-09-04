//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

/// Use cases for Articles.
public struct ArticlesUseCase: UseCase {
    
    // MARK: Properties
    private let conduit: ConduitRepository = ConduitMySQLRepository.shared

    // MARK: Initializer
    
    /// Default initializer.
    public init() {}
    

    // MARK: Use cases for articles
    
    /// This use case has work of article search.
    ///
    /// It is not considered that multiple conditions are passed at the same time.
    /// - parameters:
    ///     - author: Please pass the id of author with Int.
    ///     - feeder: Please pass the Id of the user who owns the feed with Int.
    ///     - username: Please pass the username of the user doing the favorite with String.
    ///     - tag: Please pass the tag with string.
    ///     - offset: When specifying offset, put Int here.
    ///     - limit: When specifying limit, put Int here.
    ///     - readingUserId: Please pass the id of the user reading the article.
    /// - returns:
    ///    The `Future` that returns `MultipleArticlesResponse`.
    public func getArticles( author: String? = nil, feeder: Int? = nil, favorited username: String? = nil, tag: String? = nil, offset: Int? = nil, limit: Int? = nil, readingUserId: Int? = nil) -> Future<MultipleArticlesResponse> {

        let condition = { () -> ArticleCondition in
            if let feeder = feeder { return .feed(feeder) }
            if let author = author { return .author(author) }
            if let username = username { return .favorite(username) }
            if let tag = tag { return .tag(tag) }
            return .global
        }()

        // Get article from storage.
        return conduit.articles(condition: condition, readingUserId: readingUserId, offset: offset, limit: limit)
            .map { articles in
            MultipleArticlesResponse(articles: articles, articlesCount: articles.count)
        }
    }

    ///  This use case has work of receiving the slug and get article.
    /// - parameters
    ///     - slug: Please pass the slug of the article you want to read.
    ///     - readingUserId: Please pass the id of the user reading the article.
    /// - returns:
    ///    The `Future` that returns `SingleArticleResponse`.
    public func getArticle( slug: String, readingUserId: Int? ) -> Future<SingleArticleResponse> {
        conduit.articles(condition: .slug(slug), readingUserId: readingUserId, offset: nil, limit: nil)
            .flatMapThrowing { articles in
                guard let article = articles.first else {
                    throw Error("Article by slug is not found.")
                }
                return SingleArticleResponse(article: article )
            }
    }

    /// This use case has work of article posting.
    /// - parameters:
    ///     - article: Please pass the content of the article to be posted with `NewArticle`.
    ///     - userId: Please pass the id of author with Int.
    /// - returns:
    ///    The `Future` that returns `SingleArticleResponse`. That's what you just posted.
    public func postArticle(_ article: NewArticle, author userId: Int ) -> Future<SingleArticleResponse> {
        conduit.addArticle(userId: userId, title: article.title, discription: article._description, body: article.body, tagList: article.tagList ?? [])
            .map { article in
                SingleArticleResponse(article: article )
            }
    }

    /// This use case has work of article updating.
    ///
    /// ### Extras
    /// I might have wanted to reduce the dependency on a particular type, but it was okay to use a domain model here. 😇
    /// - parameters:
    ///      - slug: Please pass the slug of the article to be updated.
    ///      - title: Please pass the title of the article. Nil means unspecified.
    ///      - description: Please pass the description of the article. Nil means unspecified.
    ///      - body: Please pass the body of the article. Nil means unspecified.
    ///      - tagList: Please pass the tags of the article. Nil means unspecified.
    ///      - readingUserId: Please pass the id of the user reading the article.
    /// - returns:
    ///    The `Future` that returns `SingleArticleResponse`. That is what you just updated.
    public func updateArticle( slug: String, title: String?, description: String?, body: String?, tagList: [String]?, readingUserId: Int? ) -> Future<SingleArticleResponse> {
        conduit.updateArticle(slug: slug, title: title, description: description, body: body, tagList: tagList, readIt: readingUserId)
            .map { article in
                SingleArticleResponse(article: article)
            }
    }

    /// This use case has work of article deleteing.
    /// - parameters:
    ///     - slug: Please pass the slug of the article to be deleted.
    /// - returns:
    ///    The `Future` that returns `Void`.
    public func deleteArticle( slug: String ) -> Future<Void> {
        conduit.deleteArticle(slug: slug)
    }

    /// This use case has work of favorite for article.
    /// - parameters:
    ///     - userId: Please pass the id of the user do the favorite.
    ///     - articleSlug: Please pass the slug of favorite article.
    /// - returns:
    ///    The `Future` that returns `SingleArticleResponse`.
    public func favorite(by userId: Int, for articleSlug: String) -> Future<SingleArticleResponse> {
        conduit.favorite(by: userId, for: articleSlug)
            .map { article in
                SingleArticleResponse(article: article)
            }
    }

    /// This use case has work of unfavorite for article.
    /// - parameters:
    ///     - userId: Please pass the id of the user do the unfavorite.
    ///     - articleSlug: Please pass the slug of unfavorite article.
    /// - returns:
    ///    The `Future` that returns `SingleArticleResponse`.
    public func unfavorite(by userId: Int, for articleSlug: String) -> Future<SingleArticleResponse> {
        conduit.unfavorite(by: userId, for: articleSlug)
            .map { article in
                SingleArticleResponse(article: article)
            }
    }

    /// This use case has work of get comments from article.
    /// - parameters:
    ///      - slug: Please pass the slug of the commented article.
    /// - returns:
    ///    The `Future` that returns `MultipleCommentsResponse`.
    public func getComments( slug: String ) -> Future<MultipleCommentsResponse> {
        conduit.comments(for: slug)
            .map { comments in
                MultipleCommentsResponse(comments: comments)
            }
    }

    /// This use case has work of post comment to article.
    /// - parameters:
    ///      - slug: Please pass the slug of articles to comment.
    ///      - body: Please pass the body of the comment.
    ///      - author: Please pass the id of the author.
    /// - returns:
    ///    The `Future` that returns `SingleCommentResponse`.
    public func postComment( slug: String, body: String, author: Int ) -> Future<SingleCommentResponse> {
        conduit.addComment(for: slug, body: body, author: author)
            .map { comment in
                SingleCommentResponse(comment: comment)
            }
    }

    /// This use case has work of delete comment to article.
    /// - parameters:
    ///      - slug: Please pass the slug of articles to uncomment.
    ///      - id: Please pass the id of the comment.
    /// - returns:
    ///    The `Future` that returns `Void`.
    public func deleteComment( slug: String, id: Int ) -> Future<Void> {
        conduit.deleteComment( for: slug, id: id )
    }
}
