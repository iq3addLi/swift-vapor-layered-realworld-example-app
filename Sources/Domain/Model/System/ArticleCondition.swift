//
//  ArticleCondition.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/21.
//

/// An enum that expresses conditions when searching for articles
public enum ArticleCondition {
    case global
    case feed(Int) // followerId
    case favorite(String) // username
    case tag(String) // tag
    case author(String) // username
    case slug(String) // slug
}
