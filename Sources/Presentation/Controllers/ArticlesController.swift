//
//  ArticlesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

final class ArticlesController {
    
    let useCase = ArticlesUseCase()
    // GET /articles
    //     /articles?offset=100&limit=3)
    //     /articles?author=johnjacob
    //     /articles?favorited=jane
    //     /articles?tag=dragons
    func getArticles(_ request: Request) throws -> String {
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        let author = request.query[ String.self, at: "author" ]
        let favorited = request.query[ String.self, at: "favorited" ]
        let tag = request.query[ String.self, at: "tag" ]
        
        useCase.getArticle()
        
        return "offset=\(String(describing: offset)), limit=\(String(describing: limit)), author=\(String(describing: author)), favorited=\(String(describing: favorited)), tag=\(String(describing: tag))"
    }
    
    // POST /articles
    func postArticle(_ request: Request) throws -> String {
        return "postArticle"
    }
    
    // GET /articles/{{slug}}
    func getArticle(_ request: Request) throws -> String {
        return "getArticle"
    }
    
    // DELETE /articles/{{slug}}
    func deleteArticle(_ request: Request) throws -> String {
        return "deleteArticle"
    }
    
    // PUT /articles/{{slug}}
    func updateArticle(_ request: Request) throws -> String {
        return "updateArticle"
    }
    

    // GET /articles/feed
    func getArticlesMyFeed(_ request: Request) throws -> String {
        return "getArticlesMyFeed"
    }
    
    // POST /articles/{{slug}}/favorite
    func postFavorite(_ request: Request) throws -> String {
        return "postFavorite"
    }
    
    // DELETE /articles/{{slug}}/favorite
    func deleteFavorite(_ request: Request) throws -> String {
        return "deleteFavorite"
    }
    
    // POST /articles/{{slug}}/comments
    func postComment(_ request: Request) throws -> String {
        return "postComment"
    }
    
    // GET /articles/{{slug}}/comments
    func getComments(_ request: Request) throws -> String {
        return "getComments"
    }
    
    // DELETE /articles/{{slug}}/comments/{{commentId}}
    func deleteComments(_ request: Request) throws -> String {
        return "deleteComments"
    }
    
}
