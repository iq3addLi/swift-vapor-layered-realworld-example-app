//
//  Users.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

import FluentKit

/// Representation of Users table.
public final class Users: Model {
    
    public static let schema = "Users"
    
    // MARK: Properties
    
    /// A Identifier.
    ///
    /// It is assumed that the value is entered on the Database side. The application does not change this value usually.
    @ID(custom: .id, generatedBy: .database)
    public var id: Int?
    
    /// A user name.
    @Field(key: "username")
    public var username: String
    
    /// A email.
    @Field(key: "email")
    public var email: String
    
    /// A biography.
    @Field(key: "bio")
    public var bio: String
    
    /// A user icon image URL.
    @Field(key: "image")
    public var image: String
    
    /// A hashed password.
    @Field(key: "hash")
    public var hash: String
    
    /// A salt added when the password is hashed.
    @Field(key: "salt")
    public var salt: String
    
    /// Follows this user
    @Children(for: \.$follower)
    public var follows: [Follows]
    
    /// Articles which this user writen.
    @Children(for: \.$author)
    public var articles: [Articles]
    
    
    // MARK: Initializer
    
    public init() { }
    
    /// Default initializer.
    /// - Parameters:
    ///   - id: See `id`.
    ///   - username: See `username`.
    ///   - email: See `email`.
    ///   - bio: See `bio`.
    ///   - image: See `image`.
    ///   - hash: See `hash`.
    ///   - salt: See `salt`.
    public init(id: Int?, username: String, email: String, bio: String = "", image: String = "", hash: String, salt: String) {
        self.id = id
        self.username = username
        self.email = email
        self.bio = bio
        self.image = image
        self.hash = hash
        self.salt = salt
    }
}


import MySQLNIO

// MARK: Create table
extension Users {

    /// Execute SQL statement for table creation.
    ///
    /// In general, you should use features provided by the following standards: https://docs.vapor.codes/3.0/fluent/models/#create
    /// - Parameter connection: A established connection.
    public static func create(on database: MySQLDatabase) -> EventLoopFuture<Void> {
        database.query("""
            CREATE TABLE IF NOT EXISTS `\(schema)` (
              `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
              `username` varchar(256) NOT NULL DEFAULT '',
              `email` varchar(1024) NOT NULL DEFAULT '',
              `bio` text NOT NULL,
              `image` varchar(1024) NOT NULL DEFAULT '',
              `hash` varchar(1024) NOT NULL DEFAULT '',
              `salt` varchar(256) NOT NULL DEFAULT '',
              `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
              `updatedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
              PRIMARY KEY (`id`),
              UNIQUE KEY `username` (`username`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
            .map{ _ in return }
    }
}


// MARK: Model
//extension Users: MySQLModel {
//    /// Table name.
//    public static var name: String {
//        return "Users"
//    }
//}

// MARK: Parent/Children relation
//extension Users {
//    
//    /// List of articles written by the user.
//    ///
//    /// ### Note
//    /// This function is not used because information related to articles must be obtained at the same time.
//    public var articles: Children<Users, Articles> {
//        return children(\.author)
//    }
//}
