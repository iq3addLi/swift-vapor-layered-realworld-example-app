//
//  UserWithFollow.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

/// Representation of a row combining Users and Follows information about them.
public final class UserWithFollowRow: Codable {
    
    // MARK: Users

    /// Same as `Users`'s id.
    public let id: Int

    /// Same as `Users`'s username.
    public let username: String

    /// Same as `Users`'s email.
    public let email: String

    /// Same as `Users`'s bio.
    public let bio: String

    /// Same as `Users`'s image.
    public let image: String

    
    // MARK: Related to Follows
    
    /// Whether the person who referenced this user information is following this user.
    public let following: Bool?

    
    // MARK: Initializer
    
    /// Default initializer.
    public init(id: Int, username: String, email: String, bio: String, image: String, following: Bool?) {
        self.id = id
        self.username = username
        self.email = email
        self.bio = bio
        self.image = image
        self.following = following
    }
}
