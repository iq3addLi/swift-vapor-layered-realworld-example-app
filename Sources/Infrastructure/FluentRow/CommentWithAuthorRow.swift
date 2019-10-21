//
//  CommentWithAuthorRow.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/18.
//

import Core // Supply Codable for Date

public final class CommentWithAuthorRow: Codable{
    // Comment
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let body: String

    // Profile
    public let username: String
    public let bio: String
    public let image: String
    public let following: Bool?
}
