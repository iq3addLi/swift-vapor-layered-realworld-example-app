//
//  ConduitFluentRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure
import FluentMySQL

public struct ConduitFluentRepository: ConduitRepository{
        
    public func ifneededPreparetion() {
        print("preparetion")
    }
    
    public func registerUser(name username: String, email: String, password: String) -> Users{
        // Dummy
        let userEntity = Users(id: 0, username: username, email: email, hash: password /* no hash */ )
        return userEntity
    }
    
    public func searchUser(email: String, password: String) -> Users?{
        // Dummy
        return nil
    }
    
    public func issuedJWTToken( id: String, username: String ) -> String{
        // Dummy
        return ""
    }
}

