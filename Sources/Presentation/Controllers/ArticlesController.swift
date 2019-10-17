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
    
    private func temporaryError(_ request: Request) -> Response{
        return request.response( GenericErrorModel(errors: GenericErrorModelErrors(body: ["It's a temporary error."])) , as: .json)
    }
    
    // GET /articles
    //     /articles?offset=100&limit=3)
    //     /articles?author=johnjacob
    //     /articles?favorited=jane
    //     /articles?tag=dragons
    //  <Auth optional>
    func getArticles(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by query
        let offset = request.query[ Int.self, at: "offset" ]
        let limit = request.query[ Int.self, at: "limit" ]
        let author = request.query[ String.self, at: "author" ]
        let favorited = request.query[ String.self, at: "favorited" ]
        let tag = request.query[ String.self, at: "tag" ]
        
        // Exec business logic
        guard let articles = try? useCase.getArticles(offset: offset, limit: limit, author: author, favorited: favorited, tag: tag) else{
            return self.temporaryError(request).encode(status: .badRequest, for: request)
        }
        
        // Success
        return try request.response( articles , as: .json).encode(for: request)
    }
    
    // POST /articles
    //  <Auth then expand payload>
    func postArticle(_ request: Request) throws -> Future<Response> {
        
        // Get relayed parameter
        let payload = (try request.privateContainer.make(SessionPayload.self))
        
        // Get parameter by body
        return try request.content.decode(json: NewArticleRequest.self, using: JSONDecoder()).then { req in
            // Exec business logic
            guard let postedArticle = try? self.useCase.postArticle( req.article, author: payload.id ) else{
                return self.temporaryError(request).encode(status: .badRequest, for: request)
            }
            
            // Success
            return request.response( postedArticle , as: .json).encode(status: .ok, for: request)
        }
    }
    
    // GET /articles/{{slug}}
    //  <Auth optional>
    func getArticle(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let slug = try? request.parameters.next(String.self) else{
            return self.temporaryError(request).encode(status: .badRequest, for: request)
        }
        
        // Exec business logic
        guard let article = try useCase.getArticle(slug: slug) else{
            return self.temporaryError(request).encode(status: .badRequest, for: request)
        }
        
        // Success
        return request.response( article , as: .json).encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}
    //  <Auth then expand payload>
    func deleteArticle(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // PUT /articles/{{slug}}
    //  <Auth then expand payload>
    func updateArticle(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    

    // GET /articles/feed
    //  <Auth optional>
    func getArticlesMyFeed(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // POST /articles/{{slug}}/favorite
    //  <Auth then expand payload>
    func postFavorite(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}/favorite
    //  <Auth then expand payload>
    func deleteFavorite(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // GET /articles/{{slug}}/comments
    //  <Auth optional>
    func getComments(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // POST /articles/{{slug}}/comments
    //  <Auth then expand payload>
    func postComment(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // DELETE /articles/{{slug}}/comments/{{commentId}}
    //  <Auth then expand payload>
    func deleteComment(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
}
