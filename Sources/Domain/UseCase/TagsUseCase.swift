//
//  TagsUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

import Foundation

public struct TagsUseCase{
    
    let conduit: ConduitRepository = ConduitMySQLRepository()
    
    public init(){}
    
    public func allTags() throws -> TagsResponse{
        return TagsResponse(tags: try conduit.allTags() )
    }
}
