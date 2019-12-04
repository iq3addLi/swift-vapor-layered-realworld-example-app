//
//  HTTPMethodInDomain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/04.
//

/// HTTPMethod in domain.
///
/// The purpose of defining this in the Domain layer is to reduce the dependency on the framework. It's also intended to clarify the HTTPMethod within the project's domain.
/// ### Note
/// Continuing from the namespace is Domain.HTTPMethodInDomain. This may seem verbose. I named it because I didn't want to confuse it with NIOHTTP1.HTTPMethod.
/// ### Extra
/// I'm want hotly for [enum subsets features](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160530/020054.html) in Swift.😊
public enum HTTPMethodInDomain {
    // MARK: Cases
    
    /// Same as `NIO.HTTPMethod.GET`
    case get
    
    /// Same as `NIO.HTTPMethod.PUT`
    case put
    
    /// Same as `NIO.HTTPMethod.POST`
    case post
    
    /// Same as `NIO.HTTPMethod.DELETE`
    case delete
}


import NIOHTTP1
// MARK: Compatibility with HTTPMethod
extension HTTPMethodInDomain {
    
    /// Convert to HTTPMethod
    public var raw: HTTPMethod {
        switch self {
        case .get: return .GET
        case .put: return .PUT
        case .post: return .POST
        case .delete: return .DELETE
        }
    }
}
