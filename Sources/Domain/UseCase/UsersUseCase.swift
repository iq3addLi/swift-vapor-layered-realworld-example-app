//
//  UsersUsecase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// Use cases for Users.
public struct UsersUseCase: UseCase {
    
    // MARK: Properties
    
    /// See `ConduitMySQLRepository`.
    private let conduit: ConduitRepository = ConduitMySQLRepository.shared
    
    /// See `JWTWithVaporRepository`.
    private let jwt: JWTRepository = JWTWithVaporRepository()

    
    // MARK: Initializer
    
    /// Default initializer.
    public init() {}
    

    // MARK: Use cases for users
    
    /// This use case has work of user login.
    /// - parameters:
    ///     - form: Please pass the information used for authentication with `LoginUser`.
    /// - returns:
    ///    The `Future` that returns `UserResponse`.
    public func login( form: LoginUser ) -> Future<UserResponse> {
        
        // Search User
        conduit.authUser(email: form.email, password: form.password)
            .flatMapThrowing { id, user in
                UserResponse(user:
                    User(email: user.email,
                         token: try self.jwt.issueJWT(id: id, username: user.username),
                         username: user.username,
                         bio: user.bio,
                         image: user.image
                    )
                )
            }
    }

    /// This use case has work of user registration.
    /// - parameters:
    ///     - form: Please pass the information used for user registration with `NewUser`.
    /// - throws:
    ///    See `JWTWithVaporRepository.issueJWT(id:username:)`.
    /// - returns:
    ///    The `Future` that returns `UserResponse`.
    public func register(user form: NewUser ) throws -> Future<UserResponse> {
        let jwt = self.jwt
        let conduit = self.conduit

        // Register user
        return try conduit.validate(username: form.username, email: form.email, password: form.password)
            .flatMap {
                conduit.registerUser(name: form.username, email: form.email, password: form.password)
            .flatMapThrowing { id, user -> UserResponse in
                // Issued JWT
                let token = try jwt.issueJWT(id: id, username: user.username)
                // Return response
                return UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
        }
    }

    /// This use case has work of `User` updating.
    /// - parameters:
    ///     - userId: Please pass the id of the user to be updated.
    ///     - token: Please pass the authenticated JWT used for this session.
    ///     - user: Please pass the information used for user updating with `UpdateUser`.
    /// - returns:
    ///    The `Future` that returns `UserResponse`. 
    public func update(userId: Int, token: String, updateUser user: UpdateUser ) -> Future<UserResponse> {

        // Update user in storage
        conduit.updateUser(id: userId, email: user.email, username: user.username, bio: user.bio, image: user.image)
            .map { user in
                UserResponse(user: User(email: user.email, token: token, username: user.username, bio: user.bio, image: user.image))
            }
    }
}
