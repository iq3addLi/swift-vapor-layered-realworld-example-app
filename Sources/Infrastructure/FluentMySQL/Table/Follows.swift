//
//  Follows.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentMySQL

public final class Follows{
    public var id: Int?
    public var followee: Int
    public var follower: Int
    public init( id: Int?, followee: Int, follower: Int ) {
        self.id = id
        self.followee = followee
        self.follower = follower
    }
}


extension Follows: MySQLModel{
    // Table name
    public static var name: String {
        return "Follows"
    }
}

// Relation
extension Follows {
    
    var followeeUser: Parent<Follows, Users>? {
        return parent(\.followee)
    }
    
    var followerUser: Parent<Follows, Users>? {
        return parent(\.follower)
    }
}

