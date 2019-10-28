//
//  ProfilesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// dummy comment
public struct ProfilesUseCase{
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    public init(){}
}

import Async
extension ProfilesUseCase{
    
    /// dummy comment
    public func profile(by username: String, readingUserId: Int? ) -> Future<ProfileResponse>{
        conduit.searchProfile(username: username, readingUserId: readingUserId)
            .map{ profile in
                ProfileResponse(profile: profile)
            }
    }
    
    /// dummy comment
    public func follow(to username: String, from userId: Int ) -> Future<ProfileResponse>{
        conduit.follow(followee: username, follower: userId)
            .map{ profile in
                ProfileResponse(profile: profile)
            }
    }
    
    /// dummy comment
    public func unfollow(to username: String, from userId: Int ) -> Future<ProfileResponse>{
        conduit.unfollow(followee: username, follower: userId)
            .map{ profile in
                ProfileResponse(profile: profile)
            }
    }
    
}
