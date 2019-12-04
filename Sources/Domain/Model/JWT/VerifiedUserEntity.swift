//
//  VerifiedUserEntity.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/22.
//

/// User information in Payload of JWT
///
/// APIs that require Payload information to complete processing are automatically expanded by Middleware and relayed to the controller.
/// See AuthenticateThenExpandPayloadMiddleware for details
/// ### Note
/// SessionPayload is a struct and has an exp that does not require a relay. I thought I should have another class.
public final class VerifiedUserEntity {
    
    // MARK: Properties
    
    /// dummy comment
    public var id: Int?

    /// dummy comment
    public var username: String?

    /// dummy comment
    public var token: String?
}

import Vapor
extension VerifiedUserEntity: ServiceType {
    
    // MARK: Functions
    
    public static func makeService(for container: Container) throws -> Self {
        return .init()
    }
}
