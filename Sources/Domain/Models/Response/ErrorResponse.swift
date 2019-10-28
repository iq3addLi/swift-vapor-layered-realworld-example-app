//
//  ErrorResponse.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/28.
//


public struct ErrorResponse: Codable{
    public let errors: [String: [String]]
}
