//
//  CommentEntity.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//


public final class Comments: Codable{
    public var body: String
    public var author: Int
    public var article: Int
    
    public init( body: String, author: Int, article: Int ) {
        self.body = body
        self.author = author
        self.article = article
    }
}


//body: String,
//author: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
//article: { type: mongoose.Schema.Types.ObjectId, ref: 'Article' }
