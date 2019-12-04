//
//  ArticleCondition.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/21.
//

/// An enum that expresses conditions when searching for articles.
public enum ArticleCondition {
    
    // MARK: Cases
    
    /// Search all data in Conduit.
    case global
    
    /// Search for articles the user following.
    case feed(Int) // followerId
    
    /// Search for articles the user favotites.
    case favorite(String) // username
    
    /// Search by tag.
    case tag(String) // tag
    
    /// Search by author.
    case author(String) // username
    
    /// Identify articles with slug.
    case slug(String) // slug
}
