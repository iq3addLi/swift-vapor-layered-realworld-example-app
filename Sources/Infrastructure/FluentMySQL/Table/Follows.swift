//
//  Follows.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentKit

/// Representation of Follows table.
public final class Follows: Model {
    
    public static let schema = "follows"
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    @ID(custom: .id, generatedBy: .database)
    public var id: Int?
    
    /// A followee. It's a `Users`'s id.
    @Field(key: "followee")
    public var followee: Int
    
    /// A follower. It's a `Users`'s id.
    @Field(key: "follower")
    public var follower: Int
    
    // MARK: Initializer
    
    public init() { }
    
    /// Default initializer.
    /// - Parameters:
    ///   - id: See `id`
    ///   - followee: See `followee`
    ///   - follower: See `follower`
    public init( id: Int?, followee: Int, follower: Int ) {
        self.id = id
        self.followee = followee
        self.follower = follower
    }
}

import MySQLNIO

// MARK: Create table
extension Follows {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
    public static func create(on database: MySQLDatabase) -> EventLoopFuture<Void> {
        database.query("""
            CREATE TABLE IF NOT EXISTS `Follows` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `followee` bigint(20) unsigned NOT NULL,
              `follower` bigint(20) unsigned NOT NULL,
              PRIMARY KEY (`id`),
              UNIQUE KEY `unique_key` (`followee`,`follower`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .map{ _ in return }
    }
}


// MARK: Model
//extension Follows: MySQLModel {
//    /// Table name.
//    public static var name: String {
//        return "Follows"
//    }
//}


// MARK: Parent/Children relation
//extension Follows {
//
//    /// A followee's detail as `Users`.
//    var followeeUser: Parent<Follows, Users>? {
//        return parent(\.followee)
//    }
//
//    /// A follower's detail as `Users`.
//    var followerUser: Parent<Follows, Users>? {
//        return parent(\.follower)
//    }
//}
