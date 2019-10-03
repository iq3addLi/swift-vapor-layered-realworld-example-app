//
//  ArticlesUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/11.
//

import Foundation

public class ArticlesUseCase{
    
    public init(){}
    
    public func getArticles( offset: Int?, limit: Int?, author: String?, favorited username: String?, tag: String? ) throws -> MultipleArticlesResponse?{
        return nil
    }
    
    public func postArticle(_ article: NewArticle ) throws -> SingleArticleResponse?{
        return nil
    }

    public func getArticle( slug: String ) throws -> SingleArticleResponse?{
        return nil
    }

    public func deleteArticle( slug: String ) throws -> Bool{
        return true
    }
    
    public func updateArticle( slug: String ) throws -> SingleArticleResponse?{
        return nil
    }
    
    public func getArticlesByUser( username: String, offset: Int?, limit: Int? ) throws -> MultipleArticlesResponse?{
        return nil
    }
    
    public func favorite( username: String ) throws -> SingleArticleResponse?{
        return nil
    }
    
    public func unfavorite( username: String ) throws -> SingleArticleResponse?{
        return nil
    }
    
    public func getComments( slug: String ) throws -> MultipleCommentsResponse?{
        return nil
    }

    public func postComment( slug: String ) throws -> SingleCommentResponse?{
        return nil
    }

    public func deleteComment( slug: String ) throws -> Bool{
        return true
    }
}
