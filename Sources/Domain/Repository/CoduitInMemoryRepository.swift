//
//  CoduitInMemoryRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import Infrastructure

public class ConduitInMemoryRepository: ConduitRepository{

    var users: [Users] = []
    
    public init(){}
    
    public func ifneededPreparetion() {
        print("preparetion")
    }
    
    public func registerUser(name username: String, email: String, password: String) -> Users{
        let userEntity = Users(id: users.count + 1, username: username, email: email, hash: password /* no hash */ )
        users.append( userEntity )
        return userEntity
    }
    
    public func searchUser(email: String, password: String) -> Users?{
        return users.filter{ $0.email == email && $0.hash == password }.first
    }
    
    public func issuedJWTToken( id: String, username: String ) -> String{
        // Dummy
        return ""
    }
}

