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
}

