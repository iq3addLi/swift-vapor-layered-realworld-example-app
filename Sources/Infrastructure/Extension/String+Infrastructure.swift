//
//  String+Infrastructure.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/11/28.
//

/// Generic extension for String
extension String {
    
    // MARK: Properties
    
    /// Make the string camel case
    public var camelcased: String {
        self.replacingOccurrences(of: "[, _-]", with: " ", options: .regularExpression).capitalized.split(separator: " ").joined()
    }
    
    // MARK: Functions
    
    /// Returns a random string
    /// - Parameter length: The length of the string
    public static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String( (0..<length).map { _ in letters.randomElement()! })
    }

}
