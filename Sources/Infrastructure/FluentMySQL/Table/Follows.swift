//
//  Follows.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Follows table
public final class Follows {
    
    // MARK: Properties
    
    public var id: Int?
    public var followee: Int
    public var follower: Int
    
    // MARK: Functions
    
    public init( id: Int?, followee: Int, follower: Int ) {
        self.id = id
        self.followee = followee
        self.follower = follower
    }
}


extension Follows {
    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Follows` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `followee` bigint(20) unsigned NOT NULL,
              `follower` bigint(20) unsigned NOT NULL,
              PRIMARY KEY (`id`),
              UNIQUE KEY `unique_key` (`followee`,`follower`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .run()
    }
}


import FluentMySQL

extension Follows: MySQLModel {
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
