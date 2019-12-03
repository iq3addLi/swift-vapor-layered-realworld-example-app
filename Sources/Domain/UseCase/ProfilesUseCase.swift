//
//  ProfilesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// Use cases for Profiles
public struct ProfilesUseCase: UseCase {
    
    // MARK: Properties
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    // MARK: Functions
    
    /// <#Description#>
    public init() {}
    

    /// <#Description#>
    /// - parameters:
    ///     - username: <#username description#>
    ///     - readingUserId: <#readingUserId description#>
    /// - returns:
    ///    <#Description#>
    public func profile(by username: String, readingUserId: Int? ) -> Future<ProfileResponse> {
        conduit.searchProfile(username: username, readingUserId: readingUserId)
            .map { profile in
                ProfileResponse(profile: profile)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///      - username: <#username description#>
    ///      - userId: <#userId description#>
    /// - returns:
    ///    <#Description#>
    public func follow(to username: String, from userId: Int ) -> Future<ProfileResponse> {
        conduit.follow(followee: username, follower: userId)
            .map { profile in
                ProfileResponse(profile: profile)
            }
    }

    /// <#Description#>
    /// - parameters:
    ///      - username: <#username description#>
    ///      - userId: <#userId description#>
    /// - returns:
    ///    <#Description#> 
    public func unfollow(to username: String, from userId: Int ) -> Future<ProfileResponse> {
        conduit.unfollow(followee: username, follower: userId)
            .map { profile in
                ProfileResponse(profile: profile)
            }
    }

}
