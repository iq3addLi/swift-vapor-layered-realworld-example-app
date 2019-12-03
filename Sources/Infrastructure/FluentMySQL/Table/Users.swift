//
//  Users.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/10.
//

/// Representation of Users table
public final class Users {
    
    // MARK: Properties
    
    public var id: Int?
    public var username: String
    public var email: String
    public var bio: String
    public var image: String
    public var hash: String // hashed password
    public var salt: String

    // MARK: Functions
    
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

extension Users {

    public static func create(on connection: MySQLConnection) -> Future<Void> {
        connection.raw("""
            CREATE TABLE IF NOT EXISTS `Users` (
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
            .run()
    }
}


import FluentMySQL
extension Users: MySQLModel {
    // Table name
    public static var name: String {
        return "Users"
    }
}

// Relation
extension Users {
    public var articles: Children<Users, Articles> {
        return children(\.author)
    }
}
