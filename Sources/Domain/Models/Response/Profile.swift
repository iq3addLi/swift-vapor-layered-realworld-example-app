//
//  Profile.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/12.
//

public struct Profile{
    public let username: String
    public let bio: String
    public let image: String
    public let following: Bool
}

import Vapor
extension Profile: Content{}
