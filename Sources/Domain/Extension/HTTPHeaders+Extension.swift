//
//  HTTPHeaders+Extension.swift
//  Main
//
//  Created by iq3AddLi on 2019/10/03.
//

import HTTP


extension HTTPHeaders {
    
    /// Access or set the `Authorization: Token ...` header.
    public var tokenAuthorization: BearerAuthorization? {
        get {
            guard let string = self[.authorization].first else {
                return nil
            }
            
            guard let range = string.range(of: "Token ") else {
                return nil
            }
            
            let token = string[range.upperBound...]
            return .init(token: String(token))
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
