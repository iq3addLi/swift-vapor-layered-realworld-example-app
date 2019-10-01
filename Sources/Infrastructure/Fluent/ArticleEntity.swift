//
//  ArticleEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

// I don't like the deep nested Protocol and the Model-dependent ORM 😢
import FluentMySQL


public final class ArticleEntity: MySQLModel{
    public var id: Int?

    public let title: String
}

extension ArticleEntity: Migration{}
