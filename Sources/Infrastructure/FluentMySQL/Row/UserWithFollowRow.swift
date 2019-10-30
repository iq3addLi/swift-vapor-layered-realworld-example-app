//
//  UserWithFollow.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

// dummy comment
public final class UserWithFollowRow: Codable{
    
    // dummy comment
    public let id: Int
    
    // dummy comment
    public let username: String
    
    // dummy comment
    public let email: String
    
    // dummy comment
    public let bio: String
    
    // dummy comment
    public let image: String
    
    // dummy comment
    public let following: Bool?
    
    // dummy comment
    public init(id: Int, username: String, email: String, bio: String, image: String, following: Bool?){
        self.id = id
        self.username = username
        self.email = email
        self.bio = bio
        self.image = image
        self.following = following
    }
}
