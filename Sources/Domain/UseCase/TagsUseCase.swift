//
//  TagsUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

import Foundation

/// dummy comment
public struct TagsUseCase{
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    public init(){}
}


import Async
extension TagsUseCase{
    /// dummy comment
    public func allTags() -> Future<TagsResponse>{
        conduit.allTags()
            .map{ tags in
                TagsResponse(tags: tags )
            }
    }
}
