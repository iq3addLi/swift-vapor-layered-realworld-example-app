//
//  HTTPMethodInDomain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/04.
//



/// HTTPMethod in domain
///
/// ### Note
/// Continuing from the namespace is Domain.HTTPMethodInDomain. This may seem verbose. I named it because I didn't want to confuse it with NIOHTTP1.HTTPMethod.
/// ### Extra
/// I'm want hotly for [enum subsets features](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160530/020054.html) in Swift.😊
public enum HTTPMethodInDomain {
    // MARK: Cases
    
    case get
    case put
    case post
    case delete
}

import NIOHTTP1

extension HTTPMethodInDomain {

    // MARK: Properties
    
    /// dummy comment
    public var raw: HTTPMethod {
        switch self {
        case .get: return .GET
        case .put: return .PUT
        case .post: return .POST
        case .delete: return .DELETE
        }
    }
}
