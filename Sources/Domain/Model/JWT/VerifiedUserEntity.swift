//
//  VerifiedUserEntity.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/22.
//

/// User information in Payload of JWT.
///
/// APIs that require Payload information to complete processing are automatically expanded by Middleware and relayed to the controller.
/// See AuthenticateThenExpandPayloadMiddleware for details.
/// ### Note
/// SessionPayload is a struct and has an exp that does not require a relay. I thought I should have another class.
public final class VerifiedUserEntity {
    
    // MARK: Properties
    
    /// Same as `SessionPayload`s id.
    public var id: Int?

    /// Same as `SessionPayload`s username.
    public var username: String?

    /// JWT used for authentication.
    public var token: String?
    
    public init( id: Int?, username: String?, token: String?){
        self.id = id
        self.username = username
        self.token = token
    }
}

import Vapor

// MARK: Storageable

extension VerifiedUserEntity {
    public struct Key: StorageKey{
        public typealias Value = VerifiedUserEntity
    }
}
