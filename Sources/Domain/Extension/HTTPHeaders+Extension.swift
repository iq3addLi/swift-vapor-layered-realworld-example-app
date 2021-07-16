//
//  HTTPHeaders+Extension.swift
//  Main
//
//  Created by iq3AddLi on 2019/10/03.
//

import Vapor

/// Extensions required by Domain.
extension HTTPHeaders {

    // MARK: Properties
    
    /// Access or set the `Authorization: Token ...` header.
    public var tokenAuthorization: BearerAuthorization? {
        get {
            guard let string = self.first(name: .authorization) else {
                return nil
            }

            let headerParts = string.split(separator: " ")
            guard headerParts.count == 2 else {
                return nil
            }
            guard headerParts[0] == "Token" else {
                return nil
            }
            return .init(token: String(headerParts[1]))
        }
        set {
            if let bearer = newValue {
                replaceOrAdd(name: .authorization, value: "Token \(bearer.token)")
            } else {
                remove(name: .authorization)
            }
        }
    }
}


import NIOHTTP1

extension HTTPHeaders{
    
    public static var jsonType: Self {
        Self([(HTTPHeaders.Name.contentType.description, HTTPMediaType.json.serialize())])
    }
    
    public static var plainTextType: Self {
        Self([(HTTPHeaders.Name.contentType.description, HTTPMediaType.plainText.serialize())])
    }
}
