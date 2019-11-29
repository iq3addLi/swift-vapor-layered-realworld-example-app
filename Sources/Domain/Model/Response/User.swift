//
// User.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

/// see https://github.com/gothinkster/realworld/blob/master/api/swagger.json
public struct User: Codable {

    public var email: String
    public var token: String
    public var username: String
    public var bio: String
    public var image: String

    public init(email: String, token: String, username: String, bio: String, image: String) {
        self.email = email
        self.token = token
        self.username = username
        self.bio = bio
        self.image = image
    }
}

import Infrastructure
extension Users {
    public func profile( following: Bool) -> Profile {
        return Profile(username: username, bio: bio, image: image, following: following)
    }
}
