//
//  Comment.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/12.
//

public struct Comment{
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let body: String
    public let author: Profile
}

import Vapor
extension Comment: Content{}
