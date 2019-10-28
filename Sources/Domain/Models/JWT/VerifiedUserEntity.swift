//
//  VerifiedUserEntity.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/22.
//


/// dummy comment
public final class VerifiedUserEntity{
    /// dummy comment
    public var id: Int?
    
    /// dummy comment
    public var username: String?
    
    /// dummy comment
    public var token: String?
}

import Vapor
extension VerifiedUserEntity: Service{}
