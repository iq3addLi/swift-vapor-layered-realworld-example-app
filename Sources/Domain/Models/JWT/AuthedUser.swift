//
//  AuthedUser.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//


public final class AuthedUser{
    public var id: Int
    public var email: String
    public var token: String
    public var username: String
    public var bio: String
    public var image: String
//    public var favorites: [Int]
//    public var following: [Int]
    
    public init(id: Int = 0, email: String = "", token: String = "", username: String = "", bio: String = "", image: String = ""/*, favorites: [Int] = [], following: [Int] = []*/){
        self.id = id
        self.email = email
        self.token = token
        self.username = username
        self.bio = bio
        self.image = image
//        self.favorites = favorites
//        self.following = following
    }
}

extension AuthedUser{
    public func toResponse() -> User{
        return User(email: email, token: token, username: username, bio: bio, image: image)
    }
}

import Vapor
extension AuthedUser: Service{} // MEMO: struct is can't be Service
