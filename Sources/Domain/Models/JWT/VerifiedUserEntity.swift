//
//  VerifiedUserEntity.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/22.
//


public final class VerifiedUserEntity{
    public var id: Int?
    public var username: String?
    public var token: String?
}

import Vapor
extension VerifiedUserEntity: Service{}
