//
//  UsersUsecase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

public struct LoginForm{
    public let email: String
    public let password: String
}

public struct UserForm{
    public let username: String
    public let email: String
    public let password: String
}


public struct UsersUseCase{
    
    public init(){}
    
    public func login( form: LoginForm ) throws -> User?{
        return nil
    }
    
    public func register(user form: UserForm ) throws -> User?{
        return nil
    }
    
    // ユーザー情報の参照は、ミドルウェアから行う
    
    public func update(user id: Int, email: String?, username: String?, bio: String?, image: String? ) throws -> User? {
        return nil
    }
}
