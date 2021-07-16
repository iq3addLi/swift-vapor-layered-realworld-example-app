//
//  Error.swift
//  Presentation
//
//  Created by Ikumi Arakane on 2020/09/03.
//

/// Presentation.Error
struct Error: Swift.Error{
    let message: String
    
    init(_ message: String ){
        self.message = message
    }
}
