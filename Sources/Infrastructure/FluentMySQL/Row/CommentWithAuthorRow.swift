//
//  CommentWithAuthorRow.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/18.
//

import Core // Supply Codable for Date

/// Representation of a row combining Comments and Users.
public final class CommentWithAuthorRow: Codable {
    
    
    // MARK: Comments
    
    /// Same as `Comments`'s id.
    public let id: Int

    /// Same as `Comments`'s createdAt.
    public let createdAt: Date

    /// Same as `Comments`'s updatedAt.
    public let updatedAt: Date

    /// Same as `Comments`'s body.
    public let body: String

    
    // MARK: Users

    /// Same as `Users`'s username.
    public let username: String

    /// Same as `Users`'s bio.
    public let bio: String

    /// Same as `Users`'s image.
    public let image: String

    
    // MARK: Related to Follows
    
    /// Whether the author of the comment is followed.
    public let following: Bool?
}
