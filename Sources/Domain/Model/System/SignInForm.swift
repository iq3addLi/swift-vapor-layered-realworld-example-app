//
//  SignInForm.swift
//  Domain
//
//  Created by Ikumi Arakane on 2020/09/03.
//

import Vapor

struct SignInForm{
    let username: String
    let email: String
    let password: String
}

extension SignInForm: Validatable{
    
    static func validations(_ validations: inout Validations) {
        
    }
}
