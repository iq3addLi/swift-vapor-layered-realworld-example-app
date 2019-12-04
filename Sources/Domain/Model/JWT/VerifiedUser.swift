//
//  AuthedUser.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//

/// Authenticated user information
///
/// APIs that require the logged-in user's own information to complete the process automatically query the user information through Middleware and relay the information to the controller.
/// @see AuthenticateThenSearchUserMiddleware for detail.
/// ### Note
/// User is a struct and has no id. This class was prepared because I wanted to use it without changing the swagger definition.
public final class VerifiedUser {
    
    // MARK: Properties
    
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

    // MARK: Functions
    /// dummy comment
    public init(id: Int = 0, email: String = "", token: String = "", username: String = "", bio: String = "", image: String = "") {
        self.id = id
        self.email = email
        self.token = token
        self.username = username
        self.bio = bio
        self.image = image
    }
}


extension VerifiedUser {
    /// dummy comment
    public var user: User {
        return User(email: email, token: token, username: username, bio: bio, image: image)
    }
}

import Vapor
// MEMO: <s>struct is can't be Service</s>
// When you want to relay a variable from Middleware to Request, you cannot make it a struct. To create a copy.
// Do not try to do the same with Service. To continue using the memory address registered with register()
extension VerifiedUser: ServiceType {
    
    /// @see ServiceType
    public static func makeService(for container: Container) throws -> Self {
        return .init()
    }
}
