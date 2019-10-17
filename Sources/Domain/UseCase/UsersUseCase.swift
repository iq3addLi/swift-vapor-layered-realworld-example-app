//
//  UsersUsecase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//


public struct UsersUseCase{
    
    let conduit: ConduitRepository = ConduitInMemoryRepository()
    let jwt: JWTRepository = JWTWithVaporRepository()
    
    public init(){}
    
    public func login( form: LoginUser ) throws -> UserResponse?{
        // Search User
        guard let (id, user) = conduit.searchUser(email: form.email, password: form.password) else{
            return nil
        }
        
        // Issued JWT
        let token = try jwt.issuedJWTToken(id: id, username: user.username)
        
        // Return response
        return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
    }
    
    public func register(user form: NewUser ) throws -> UserResponse?{
        
        // Register user
        let (id, user) = conduit.registerUser(name: form.username, email: form.email, password: form.password)
        
        // Issued JWT
        let token = try jwt.issuedJWTToken(id: id, username: user.username)
        
        // Return response
        return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
    }
    
    public func currentUser( token: String ) throws -> UserResponse? {
        
        // Verify and expand payload
        let session = try jwt.verifyJWTToken(token: token)
        
        // Search user in storage
        guard let user = conduit.searchUser(id: session.id) else{
            return nil
        }
        
        return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
    }
    
    public func update(userId: Int, updateUser user: UpdateUser, token: String ) throws -> UserResponse? {
        
        // Update user in storage
        guard let user = conduit.updateUser(id: userId, email: user.email, username: user.username, bio: user.bio, image: user.image) else{
            return nil
        }
        
        return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
    }
}
