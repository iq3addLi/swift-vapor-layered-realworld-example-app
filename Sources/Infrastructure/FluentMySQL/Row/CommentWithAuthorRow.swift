//
//  CommentWithAuthorRow.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/18.
//

import Core // Supply Codable for Date

/// dummy comment
public final class CommentWithAuthorRow: Codable {
    // Comment

    // dummy comment
    public let id: Int

    // dummy comment
    public let createdAt: Date

    // dummy comment
    public let updatedAt: Date

    // dummy comment
    public let body: String

    // Profile

    // dummy comment
    public let username: String

    // dummy comment
    public let bio: String

    // dummy comment
    public let image: String

    // dummy comment
    public let following: Bool?
}
