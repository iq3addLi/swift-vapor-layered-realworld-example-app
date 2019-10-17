//
// UpdateArticle.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UpdateArticle: Codable {

    public var title: String?
    public var _description: String?
    public var body: String?

    public init(title: String?, _description: String?, body: String?) {
        self.title = title
        self._description = _description
        self.body = body
    }

    public enum CodingKeys: String, CodingKey { 
        case title
        case _description = "description"
        case body
    }


}
