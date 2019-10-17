//
//  ConduitFluentRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure
import FluentMySQL

struct ConduitFluentRepository: ConduitRepository{
    
        
    func ifneededPreparetion() {
        print("preparetion")
    }
    
    func registerUser(name username: String, email: String, password: String) -> ( userId: Int, user: User ){
        // Dummy
        let userEntity = User(email: "", token: "", username: "", bio: "", image: "")
        return ( 1, userEntity )
    }
    
    func searchUser(email: String, password: String) -> ( userId: Int, user: User)?{
        // Dummy
        return nil
    }
    
    func searchUser(id: Int) -> User?{
        // Dummy
        return nil
    }
    
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> User?{
        // Dummy
        return nil
    }
    
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Article? {
        // Dummy
        return nil
    }
        
    func getArticles( offset: Int?, limit: Int?, author: String?, favorited username: String?, tag: String? ) throws -> [Article]{
        // Dummy
        return []
    }
    
    func allTags() throws -> [String]{
        // Dummy
        return []
    }
}

