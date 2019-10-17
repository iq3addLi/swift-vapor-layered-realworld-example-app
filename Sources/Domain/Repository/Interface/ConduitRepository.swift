//
//  ConduitRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure

public protocol ConduitRepository{
    
    func ifneededPreparetion()
    
    // Users
    @discardableResult
    func registerUser(name username: String, email: String, password: String) -> ( userId: Int, user: User)
    
    func searchUser(email: String, password: String) -> ( userId: Int, user: User)?
    
    func searchUser(id: Int) -> User?
    
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> User?
    
    // Articles
    @discardableResult
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) throws -> Article?
    
    func getArticles( offset: Int?, limit: Int?, author: String?, favorited username: String?, tag: String? ) throws -> [Article]
    
    // Tags
    func allTags() throws -> [String]
}
