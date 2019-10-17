//
//  HTTPMethodInDomain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/04.
//


// MEMO: I'm want hotly for enum subsets features in Swift.😊
// https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160530/020054.html

public enum HTTPMethodInDomain{
    case get
    case put
    case post
    case delete
}


import NIOHTTP1

extension HTTPMethodInDomain{
    
    public var raw: HTTPMethod {
        switch self{
        case .get: return .GET
        case .put: return .PUT
        case .post: return .POST
        case .delete: return .DELETE
        }
    }
}
