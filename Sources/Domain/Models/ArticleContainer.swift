//
//  ArticleContainer.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/12.
//

public struct ArticleContainer{
    public let count: Int
    public let articles: [Article]
}

import Vapor
extension ArticleContainer: Content{}
