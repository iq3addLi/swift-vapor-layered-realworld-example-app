//
//  String+Infrastructure.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/11/28.
//

extension String {

    public static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String( (0..<length).map { _ in letters.randomElement()! })
    }

    public var camelcased: String {
        self.replacingOccurrences(of: "[, _-]", with: " ", options: .regularExpression).capitalized.split(separator: " ").joined()
    }
}
