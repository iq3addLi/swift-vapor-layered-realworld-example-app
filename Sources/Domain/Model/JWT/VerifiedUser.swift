//
//  AuthedUser.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//

/// Authenticated user information.
///
/// APIs that require the logged-in user's own information to complete the process automatically query the user information through Middleware and relay the information to the controller.
/// @see AuthenticateThenSearchUserMiddleware for detail.
/// ### Note
/// User is a struct and has no id. This class was prepared because I wanted to use it without changing the swagger definition.
public final class VerifiedUser {
    
    // MARK: Properties
    
    /// Same as `User`s id.
    public var id: Int

    /// Same as `User`s email.
    public var email: String

    /// JWT used for authentication.
    public var token: String

    /// Same as `User`s username.
    public var username: String

    /// Same as `User`s bio.
    public var bio: String

    /// Same as `User`s image.
    public var image: String

    // MARK: Initalizer
    
    /// Default initalizer.
    /// - Parameters:
    ///   - id: `User`s Id.
    ///   - email: `User`s email.
    ///   - token: Verified JWT.
    ///   - username: `User`s username.
    ///   - bio: `User`s bio.
    ///   - image: `User`s image.
    public init(id: Int = 0, email: String = "", token: String = "", username: String = "", bio: String = "", image: String = "") {
        self.id = id
        self.email = email
        self.token = token
        self.username = username
        self.bio = bio
        self.image = image
    }
}


// MARK: Export to User

extension VerifiedUser {
    /// Export to `User`.
    public var user: User {
        return User(email: email, token: token, username: username, bio: bio, image: image)
    }
}

import Vapor

// MARK: Storageable

extension VerifiedUser {
    public struct Key: StorageKey{
        public typealias Value = VerifiedUser
    }
}


// MARK: Implementation as ServiceType

/// Implementation as ServiceType.
///
/// ### Extras
/// When you want to relay a variable from Middleware to Request, you cannot make it a struct. To create a copy.
/// Do not try to do the same with Service. To continue using the memory address registered with register().
//extension VerifiedUser: ServiceType {
//
//    /// See `ServiceType`.
//    /// - throws:
//    ///    Conforms to protocol. It does not happen logically.
//    /// - returns:
//    ///    Instance with no value.
//    public static func makeService(for container: Container) throws -> Self {
//        return .init()
//    }
//}
