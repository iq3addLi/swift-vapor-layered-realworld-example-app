//
// SingleArticleResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

/// see https://github.com/gothinkster/realworld/blob/master/api/swagger.json
public struct SingleArticleResponse: Codable {

    public var article: Article

    public init(article: Article) {
        self.article = article
    }

}
