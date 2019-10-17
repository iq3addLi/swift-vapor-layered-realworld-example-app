//
//  Users.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentMySQL

public final class Users{
    public var id: Int?
    public var username: String
    public var email: String
    public var bio: String
    public var image: String
    public var hash: String // hashed password
    public var salt: String
    
    public init(id: Int?, username: String, email: String, bio: String = "", image: String = "", hash: String, salt: String) {
        self.id = id
        self.username = username
        self.email = email
        self.bio = bio
        self.image = image
        self.hash = hash
        self.salt = salt
    }
}

extension Users: MySQLModel{
    // Table name
    public static var name: String {
        return "Users"
    }
}

// Relation
extension Users {
    public var articles: Children<Users, Articles> {
        return children(\.author)
    }
}


