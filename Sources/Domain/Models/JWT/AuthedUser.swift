//
//  AuthedUser.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//


/// dummy comment
public final class AuthedUser{
    /// dummy comment
    public var id: Int
    
    /// dummy comment
    public var email: String
    
    /// dummy comment
    public var token: String
    
    /// dummy comment
    public var username: String
    
    /// dummy comment
    public var bio: String
    
    /// dummy comment
    public var image: String
//    public var favorites: [Int]
//    public var following: [Int]
    
    /// dummy comment
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
    /// dummy comment
    public func toResponse() -> User{
        return User(email: email, token: token, username: username, bio: bio, image: image)
    }
}

import Vapor
extension AuthedUser: Service{} // MEMO: struct is can't be Service
