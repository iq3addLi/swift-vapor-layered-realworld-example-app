//
//  ProfilesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

public struct ProfilesUseCase{
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    public init(){}
    
    public func profile(by username: String, readingUserId: Int? ) throws -> ProfileResponse{
        let profile = try conduit.searchProfile(username: username, readingUserId: readingUserId)
        return ProfileResponse(profile: profile)
    }
    
    public func follow(to username: String, from userId: Int ) throws  -> ProfileResponse{
        let profile = try conduit.follow(followee: username, follower: userId)
        return ProfileResponse(profile: profile)
    }
    
    public func unfollow(to username: String, from userId: Int ) throws -> ProfileResponse{
        let profile = try conduit.unfollow(followee: username, follower: userId)
        return ProfileResponse(profile: profile)
    }
    
}
