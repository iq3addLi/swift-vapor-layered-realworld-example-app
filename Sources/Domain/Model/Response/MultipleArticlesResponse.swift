//
// MultipleArticlesResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

/// see https://github.com/gothinkster/realworld/blob/master/api/swagger.json
public struct MultipleArticlesResponse: Codable {

    public var articles: [Article]
    public var articlesCount: Int

    public init(articles: [Article], articlesCount: Int) {
        self.articles = articles
        self.articlesCount = articlesCount
    }
}
