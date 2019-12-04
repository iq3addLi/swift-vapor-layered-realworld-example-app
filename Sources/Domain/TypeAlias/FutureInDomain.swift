//
//  FutureInDomain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//

import NIO

/// Convenience shorthand for `EventLoopFuture`.
///
/// Vapor also has this definition. The definition in Domain is to reduce the dependency on the framework by one step.
public typealias Future = EventLoopFuture

/// Convenience shorthand for `EventLoopPromise`.
///
/// Vapor also has this definition. The definition in Domain is to reduce the dependency on the framework by one step.
public typealias Promise = EventLoopPromise
