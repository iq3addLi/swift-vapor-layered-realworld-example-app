//
//  Follows.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Follows table.
public final class Follows {
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    public var id: Int?
    
    /// A followee. It's a `Users`'s id.
    public var followee: Int
    
    /// A follower. It's a `Users`'s id.
    public var follower: Int
    
    // MARK: Initializer
    
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

// MARK: Create table
extension Follows {
    
    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
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

// MARK: Model
extension Follows: MySQLModel {
    /// Table name.
    public static var name: String {
        return "Follows"
    }
}


// MARK: Parent/Children relation
extension Follows {

    /// A followee's detail as `Users`.
    var followeeUser: Parent<Follows, Users>? {
        return parent(\.followee)
    }

    /// A follower's detail as `Users`.
    var followerUser: Parent<Follows, Users>? {
        return parent(\.follower)
    }
}
