//
//  AuthController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct UsersController {
    
    let useCase = UsersUseCase()
    
    // POST /users
    func postUser(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    //    ### /user/login [POST]
    //
    //    ログインAPI。ユーザー、パスワードを送信して認証トークンを得る。
    //
    //    #### Request
    //
    //    ```json
    //    {
    //    "user": {
    //    "email": "string",
    //    "password": "string"
    //    }
    //    }
    //    ```
    //
    //
    //
    //    #### Resposne
    //
    //    200 正常終了
    //
    //    ログインしたユーザーの情報が帰ってくる
    //
    //    ```json
    //    {
    //    "user": {
    //    "email": "string",
    //    "token": "string",
    //    "username": "string",
    //    "bio": "string",
    //    "image": "string"
    //    }
    //    }
    //    ```
    // POST /users/login
    func login(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    

    // GET /user
    func getUser(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // PUT /user
    func updateUser(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
}
