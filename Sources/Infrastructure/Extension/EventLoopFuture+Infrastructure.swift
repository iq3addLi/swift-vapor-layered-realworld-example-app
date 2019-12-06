//
//  EventLoopFuture+Infrastructure.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/23.
//

import NIO

/// Extension for Array EventLoopFuture.
public extension Array where Element == EventLoopFuture<Void> {

    // MARK: Functions
    
    /// Serialize Future array.
    ///
    /// - warning:
    ///    May be used only when the result of Future can be discarded.
    /// - returns:
    ///    One future that implements array futures in series. If the array is empty, .none is returned.
    func serializedFuture() -> EventLoopFuture<Void>? {
//        var serializedFuture: EventLoopFuture<Void>?
//
//        self.forEach { future in
//            if serializedFuture != nil {
//                serializedFuture = serializedFuture.flatMap { _ in future }
//            } else {
//                serializedFuture = future
//            }
//        }
//
//        return serializedFuture

        self.reduce(into: self.first) { (future, next) in
            guard future != next else { return }
            _ = future.flatMap { _ in next }
        }
    }

}
