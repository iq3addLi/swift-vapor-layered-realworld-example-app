//
//  CryptoTests.swift
//  AppTests
//
//  Created by iq3AddLi on 2019/10/16.
//

import XCTest
import CryptoSwift

final class CryptoTests: XCTestCase {

    func testPBKDF2() throws {
        
        // Variables
        let password: Array<UInt8> = Array("password".utf8)
        let salt: Array<UInt8> = Array("salt".utf8)
        let hash = "c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a"
        
        // Calculate hash
        let bytes = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, keyLength: 32, variant: .sha256).calculate()
        let newHash = bytes.toHexString()
//        guard let newHash = String(bytes: bytes, encoding: .utf8) else{
//            XCTFail(); return
//        }
        // Examing
        XCTAssertTrue(newHash == hash)
    }
}

//extension Data {
//    var hexString : String {
//        return self.reduce("") { (a : String, v : UInt8) -> String in
//            return a + String(format: "%02x", v)
//        }
//    }
//}
