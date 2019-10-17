//
//  UserWithFollow.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

public final class UserWithFollowRow: Codable{
    public let id: Int
    public let username: String
    public let email: String
    public let bio: String
    public let image: String
    public let following: Bool?
    
    public init(id: Int, username: String, email: String, bio: String, image: String, following: Bool?){
        self.id = id
        self.username = username
        self.email = email
        self.bio = bio
        self.image = image
        self.following = following
    }
}
