//
//  UsersUsecase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//


/// <#Description#>
public struct UsersUseCase{
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    private let jwt: JWTRepository = JWTWithVaporRepository()
    
    
    /// <#Description#>
    public init(){}
}

import Async
extension UsersUseCase{
    
    
    /// <#Description#>
    /// - parameters:
    ///     - form: <#form description#>
    /// - returns:
    ///    <#Description#>
    public func login( form: LoginUser ) -> Future<UserResponse>{
        let jwt = self.jwt
        // Search User
        return conduit.authUser(email: form.email, password: form.password)
            .map{ tuple -> UserResponse in
                let (id, user) = tuple
                // Issued JWT
                let token = try jwt.issuedJWTToken(id: id, username: user.username)
                // Return response
                return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
    }
    
    /// <#Description#>
    /// - parameters:
    ///     - form: <#form description#>
    /// - returns:
    ///    <#Description#>
    public func register(user form: NewUser ) -> Future<UserResponse>{
        let jwt = self.jwt
        // Register user
        return conduit.registerUser(name: form.username, email: form.email, password: form.password)
            .map{ tuple -> UserResponse in  /* MEMO: Closure tuple parameter '(Int, User)' does not support destructuring when Swift 5.1 */
                let (id, user) = tuple
                // Issued JWT
                let token = try jwt.issuedJWTToken(id: id, username: user.username)
                // Return response
                return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
    }
    
    
    /// <#Description#>
    /// - parameters:
    ///     - token: <#token description#>
    /// - returns:
    ///    <#Description#>
    /// - throws:
    ///  <#Description#> 
    public func currentUser( token: String ) throws -> Future<UserResponse> {
        
        // Verify and expand payload
        let payload = try jwt.verifyJWTToken(token: token)
        
        // Search user in storage
        return conduit.searchUser(id: payload.id)
            .map{ tuple in
                let (_, user) = tuple
                // Return response
                return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
    }
    
    
    /// <#Description#>
    /// - parameters:
    ///      - userId: <#userId description#>
    ///      - token: <#token description#>
    /// - returns:
    ///    <#Description#>
    public func current( userId: Int, token: String ) -> Future<UserResponse> {
        
        conduit.searchUser(id: userId)
            .map{ tuple in
                let (_, user) = tuple
                // Return response
                return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
    }
    
    
    /// <#Description#>
    /// - parameters:
    ///     - userId: <#userId description#>
    ///     - token: <#token description#>
    ///     - user: <#user description#>
    /// - returns:
    ///    <#Description#>
    public func update(userId: Int, token: String, updateUser user: UpdateUser ) -> Future<UserResponse> {
        
        // Update user in storage
        conduit.updateUser(id: userId, email: user.email, username: user.username, bio: user.bio, image: user.image)
            .map{ user in
                UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
    }
}
