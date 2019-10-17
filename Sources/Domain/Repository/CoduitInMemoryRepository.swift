//
//  CoduitInMemoryRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import Foundation
import Infrastructure

private var users: [Users] = []
private var articles: [Articles] = []
private var comments: [Comments] = []
private var tags: [Tags] = []
private var follows: [Follows] = []
private var favorites: [Favorites] = []

class ConduitInMemoryRepository: ConduitRepository{
    
    init(){
        // Stub
        let user = Users(id: users.count + 1, username: "StubUser", email: "stub@stub.com", hash: "stubstub", salt: "salt")
        users.append( user )
        let article = Articles(id:  articles.count + 1, slug:  randomString(length: 16), title: "This article is stub", description: "Stub is temporary alternative.", body: "# Hello World!", author: user.id!)
        articles.append( article )
    }
    
    func ifneededPreparetion() {
        print("preparetion")
    }
    
    func registerUser(name username: String, email: String, password: String) -> ( userId: Int, user: User ){
        // Hash password with salt
        let salt = "_salt"// TODO: temporaly
        let hash = password + salt // TODO: temporaly
        
        // Append record
        let user = Users(id: users.count + 1, username: username, email: email, hash: hash, salt: salt)
        users.append( user )
        
        // Record exchange to response
        return ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image ))
    }
    
    func searchUser(email: String, password: String) -> ( userId: Int, user: User )?{
        // Search row
        guard let user = users.filter({ $0.email == email && $0.hash == password }).first else{ return nil }
        
        // Record exchange to response
        return ( user.id!, User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image ))
    }
    
    func searchUser(id: Int) -> User?{
        // Search row
        guard let user = users.filter({ $0.id == id }).first else{ return nil }
        
        // Record exchange to response
        return User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image )
    }
    
    func updateUser(id: Int, email: String?, username: String?, bio: String?, image: String? ) -> User?{
        // Search row
        guard let user = users.filter({ $0.id == id }).first else{
            // User is not found
            return nil
        }
        // Update record
        email.map { user.email = $0 }
        username.map { user.username = $0 }
        bio.map { user.bio = $0 }
        image.map { user.image = $0 }
        
        // Record exchange to response
        return User(email: user.email, token: "", username: user.username, bio: user.bio, image: user.image )
    }
    
    func getArticles( offset: Int?, limit: Int?, author: String?, favorited username: String?, tag: String? ) throws -> [Article]{

        // Records exchange to response
        return articles.compactMap{ row in
            // Search Tags
            let tagList = tags.filter{ $0.article == row.id }.map{ $0.tag }
            
            // Search User
            let profile = users.filter{ $0.id == row.author }.map{ Profile(username: $0.username, bio: $0.bio, image: $0.image, following: false) }.first // TODO: Get following
            
            return Article(slug: row.slug, title: row.title, _description: row.description, body: row.body, tagList: tagList, createdAt: row.createdAt!, updatedAt: row.updatedAt!, favorited: false, favoritesCount: 0, author: profile!) // TODO: Get favorite
        }
    }
    
    func addArticle(userId author: Int, title: String, discription: String, body: String, tagList: [String]) -> Article?{
        // Add article to storage
        let article = Articles(id: articles.count + 1, slug: randomString(length: 16), title: title, description: discription, body: body, author: author, createdAt: Date(), updatedAt: Date())
        articles.append(article)
        
        // Exchange string to Tags record then store
        tagList.forEach{
            tags.append( Tags(id: tags.count + 1, article: article.id!, tag: $0 ) )
        }
        
        // Record exchange to response
        return Article(slug: article.slug, title: article.title, _description: article.description, body: article.body, tagList: tagList, createdAt: article.createdAt!, updatedAt: article.updatedAt!, favorited: false, favoritesCount: 0, author: users.filter{ $0.id == author }.map{ Profile(username: $0.username, bio: $0.bio, image: $0.image, following: false) }.first! )
    }
    
    func allTags() throws -> [String]{
        return Array(Set(tags.map{ $0.tag }))
    }
}


private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
