//
// TagsResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

/// see https://github.com/gothinkster/realworld/blob/master/api/swagger.json
public struct TagsResponse: Codable {

    public var tags: [String]

    public init(tags: [String]) {
        self.tags = tags
    }

}
