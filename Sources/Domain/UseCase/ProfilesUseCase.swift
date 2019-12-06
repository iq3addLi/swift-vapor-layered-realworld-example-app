//
//  ProfilesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// Use cases for Profiles
public struct ProfilesUseCase: UseCase {
    
    // MARK: Properties
    
    /// See `ConduitMySQLRepository`.
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    
    // MARK: Initalizer
    
    /// Default initializer
    public init() {}
    
    
    // MARK: Use cases for profiles
    
    /// This use case has work of get profile.
    /// - parameters:
    ///     - username: Please pass the name of user who is the owner of profile.
    ///     - readingUserId: Please pass the id of the user reading the profile.
    /// - returns:
    ///   The `Future` that returns `ProfileResponse`.
    public func profile(by username: String, readingUserId: Int? ) -> Future<ProfileResponse> {
        conduit.searchProfile(username: username, readingUserId: readingUserId)
            .map { profile in
                ProfileResponse(profile: profile)
            }
    }

    /// This use case has work of follow user.
    /// - parameters:
    ///      - username: Please pass the name of the user who is Followee.
    ///      - userId: Please pass the id of the user who is Follower.
    /// - returns:
    ///   The `Future` that returns `ProfileResponse`.
    public func follow(to username: String, from userId: Int ) -> Future<ProfileResponse> {
        conduit.follow(followee: username, follower: userId)
            .map { profile in
                ProfileResponse(profile: profile)
            }
    }

    /// This use case has work of unfollow user.
    /// - parameters:
    ///      - username: Please pass the name of the user who be unfollowed.
    ///      - userId: Please pass the id of the user who is stop following.
    /// - returns:
    ///   The `Future` that returns `ProfileResponse`.
    public func unfollow(to username: String, from userId: Int ) -> Future<ProfileResponse> {
        conduit.unfollow(followee: username, follower: userId)
            .map { profile in
                ProfileResponse(profile: profile)
            }
    }

}
