//
//  Application.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public func applciationMain() throws{
    
    let useCase = ApplicationUseCase()
    
    try useCase.initialize()
    let controller = ArticlesController()
    useCase.routing(collections: [
        Domain.APICollection(method: .GET, paths: ["articles"], closure: controller.getArticles )
    ])
    try useCase.launch()
}

