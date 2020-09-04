//
//  NIOTests.swift
//  AppTests
//
//  Created by iq3AddLi on 2019/10/15.
//

import XCTest
import NIO

final class NIOTests: XCTestCase {
    
    func testEventLoopExecute() throws {
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        var result = ""
        evGroup.next().execute { // Note: Exactly non blocking. It's executed without waiting for the current block to finish.
            result += "Hello"
        }
        evGroup.next().execute {
            result += "World"
        }
        evGroup.next().execute {
            result += "!!"
        }
        
        usleep(1000)
        
        // Examining
        XCTAssertTrue(result.count == 12) // Note: Processing order is not promised
        
        try evGroup.syncShutdownGracefully()
    }
    
    func testFutureWhenSuccess() throws {
        
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        
        let future = evGroup.next().submit {
            return "Hello"
        }
        
        future.whenSuccess { (count) in
            print("Success")
        }
        future.whenFailure { error in
            XCTFail()
        }
        
        _ = try future.wait()
        
        // Collect eventLoopGroup
        try evGroup.syncShutdownGracefully()
    }
    
    func testPromise() throws {
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let promises = [ "Hello", "World", "!!" ].map { string -> EventLoopPromise<String> in
            let eventloop = evGroup.next()
            let promise = eventloop.makePromise(of: String.self)
            eventloop.execute {
                promise.succeed(string)
            }
            return promise
        }
        let future = EventLoopFuture.reduce("", promises.map{ $0.futureResult }, on: evGroup.next()) { (concated: String, text: String) in
            return concated + text
        }
        let result = try future.wait()

        // Examining
        XCTAssertTrue(result == "HelloWorld!!")

        try evGroup.syncShutdownGracefully()
    }
    
    func testFutureFold() throws {
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let future1 = evGroup.next().submit {
            return "Hello"
        }
        let future2 = evGroup.next().submit {
            return "World"
        }
        let future3 = evGroup.next().submit {
            return "!!"
        }
        let eventloop = evGroup.next()
        let succeeded = eventloop.makeSucceededFuture("")
        
        // Note: that all futures are executed when fold and reduce are called.
        let future = succeeded.fold([future1, future2, future3]) { (concated, text) -> EventLoopFuture<String> in
            eventloop.makeSucceededFuture(concated + text)
        }
        let result = try future.wait() // Note: Only the combiningFunction is executed here
        
        // Examining
        XCTAssertTrue(result == "HelloWorld!!")
        
        try evGroup.syncShutdownGracefully()
    }
    
    func testFutureReduce() throws {
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let future1 = evGroup.next().submit {
            return "Hello"
        }
        let future2 = evGroup.next().submit {
            return "World"
        }
        let future3 = evGroup.next().submit {
            return "!!"
        }
        let future = EventLoopFuture.reduce("", [future1, future2, future3], on: evGroup.next()) { (concated: String, text: String) in
            return concated + text
        }
        let result = try future.wait()
        
        // Examining
        XCTAssertTrue(result == "HelloWorld!!")
        
        try evGroup.syncShutdownGracefully()
    }
    
    func testFuturesWhenAll() throws {
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // Futures
        let future1 = evGroup.next().submit {
            return "Hello"
        }
        let future2 = evGroup.next().submit {
            return "World"
        }
        let future3 = evGroup.next().submit {
            return "!!"
        }
        
        // When all finished future
        let future = EventLoopFuture.whenAllSucceed([future1, future2, future3], on: evGroup.next()).map { strings in
            return strings.joined()
        }
        
        // run
        let result = try future.wait()
        
        // Examining
        XCTAssertTrue(result == "HelloWorld!!")
        
        try evGroup.syncShutdownGracefully()
    }
    
    func testFuturesWhenFailure() throws {
        // Create EventLoopGroup
        let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // Futures
        let future1 = evGroup.next().submit {
            return "Hello"
        }
        let future2 = evGroup.next().submit {
            return "World"
        }
        let future3 = evGroup.next().submit { () -> String in
            throw TestError(reason: "Exception")
        }
        
        // When all finished future
        let future = EventLoopFuture.whenAllSucceed([future1, future2, future3], on: evGroup.next())
        
        // run
        do{
            _ = try future.wait()
            XCTFail()
        }
        catch( let error ){
            print(error.localizedDescription)
        }
        
        try evGroup.syncShutdownGracefully()
    }
}

struct TestError: Error{
    let reason: String
}
