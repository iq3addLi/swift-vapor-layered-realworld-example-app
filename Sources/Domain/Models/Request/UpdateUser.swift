//
// UpdateUser.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UpdateUser: Codable {

    public var email: String?
    public var token: String?    // MEMO: Why is token here?
    public var username: String?
    public var bio: String?
    public var image: String?

    public init(email: String?, token: String?, username: String?, bio: String?, image: String?) {
        self.email = email
        self.token = token
        self.username = username
        self.bio = bio
        self.image = image
    }


}

