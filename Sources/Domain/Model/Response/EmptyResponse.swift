//
//  EmptyResponse.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/29.
//

/// Response expressing that there is an empty JSON body
///
/// Although it seems like a class that does not need to be, it was necessary because the behavior on the client side would change.
public struct EmptyResponse: Codable {
    public init(){}
}
