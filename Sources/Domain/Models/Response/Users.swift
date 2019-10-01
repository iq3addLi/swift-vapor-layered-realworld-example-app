//
//  User.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/12.
//

public struct User{
    public let id: Int
    public let email: String
    public let createdAt: String
    public let updatedAt: String
    public let username: String
    public let token: String
    public let bio: String?
    public let image: String?
}

import Vapor
extension User: Content{}
