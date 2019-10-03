//
//  ConduitRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/12.
//

import Infrastructure

public protocol ConduitRepository{
    
    func ifneededPreparetion()
    
    func registerUser(name username: String, email: String, password: String) -> Users
    
    func searchUser(email: String, password: String) -> Users?
    
}
