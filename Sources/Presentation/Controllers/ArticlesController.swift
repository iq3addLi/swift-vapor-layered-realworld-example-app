//
//  ArticlesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct ArticlesController {
    
    let useCase = ArticlesUseCase()
    
    // GET /articles
    //     /articles?offset=100&limit=3)
    //     /articles?author=johnjacob
    //     /articles?favorited=jane
    //     /articles?tag=dragons
    func getArticles(_ request: Request) throws -> Future<Response> {
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        let author = request.query[ String.self, at: "author" ]
        let favorited = request.query[ String.self, at: "favorited" ]
        let tag = request.query[ String.self, at: "tag" ]
        
        return request.response( GeneralInfomation("offset=\(String(describing: offset)), limit=\(String(describing: limit)), author=\(String(describing: author)), favorited=\(String(describing: favorited)), tag=\(String(describing: tag))") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // POST /articles
    func postArticle(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // GET /articles/{{slug}}
    func getArticle(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}
    func deleteArticle(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // PUT /articles/{{slug}}
    func updateArticle(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    

    // GET /articles/feed
    func getArticlesMyFeed(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // POST /articles/{{slug}}/favorite
    func postFavorite(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}/favorite
    func deleteFavorite(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    
    // GET /articles/{{slug}}/comments
    func getComments(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // POST /articles/{{slug}}/comments
    func postComment(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}/comments/{{commentId}}
    func deleteComment(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
}
