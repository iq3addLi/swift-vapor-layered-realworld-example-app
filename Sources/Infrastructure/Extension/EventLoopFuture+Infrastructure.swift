//
//  EventLoopFuture+Infrastructure.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/23.
//

import Async

//public extension Array where Element == EventLoopFuture<Any> {
//    
//    /// Serialize Future array
//    ///
//    /// @warning May be used only when the result of Future can be discarded
//    func serialization() -> EventLoopFuture<Any>?{
//        var serializedFuture: EventLoopFuture<Any>?
//        
//        self.forEach { future in
//            if serializedFuture != nil{
//                serializedFuture = serializedFuture.flatMap{ _ in future }
//            }else{
//                serializedFuture = future
//            }
//        }
//        
//        return serializedFuture
//    }
//}

public extension Array where Element == EventLoopFuture<Void> {
    
    /// Serialize Future array
    ///
    /// @warning May be used only when the result of Future can be discarded
    func serializedFuture() -> EventLoopFuture<Void>?{
        var serializedFuture: EventLoopFuture<Void>?
        
        self.forEach { future in
            if serializedFuture != nil{
                serializedFuture = serializedFuture.flatMap{ _ in future }
            }else{
                serializedFuture = future
            }
        }
        
        return serializedFuture
    }
    
}
