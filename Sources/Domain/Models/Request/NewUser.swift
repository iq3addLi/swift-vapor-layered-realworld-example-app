//
// NewUser.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//


public struct NewUser: Codable {

    public var username: String
    public var email: String
    public var password: String

    public init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }


}

