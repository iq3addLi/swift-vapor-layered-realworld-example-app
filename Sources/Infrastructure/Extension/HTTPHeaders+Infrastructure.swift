//
//  HTTPHeaders+Infrastructure.swift
//  swift-vapor-layered-realworld-example
//
//  Created by Ikumi Arakane on 2020/09/04.
//

import NIOHTTP1
import Vapor

extension HTTPHeaders{
    
    public static var jsonType: Self {
        Self([(HTTPHeaders.Name.contentType.description, HTTPMediaType.json.serialize())])
    }
    
    public static var plainTextType: Self {
        Self([(HTTPHeaders.Name.contentType.description, HTTPMediaType.plainText.serialize())])
    }
}
