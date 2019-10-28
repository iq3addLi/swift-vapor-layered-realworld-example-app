//
//  AuthPolicy.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// dummy comment
public enum AuthPolicy{
    /// Authentication required
    case require
    
    /// Authentication is optional
    case optional
    
    /// No authentication required
    case none
}
