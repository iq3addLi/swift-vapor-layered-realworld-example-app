// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "swift-vapor-layered-realworld-example",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "realworld", targets: ["realworld"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(name: "vapor", url: "https://github.com/vapor/vapor", from: "4.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc)
        .package(name: "fluent-mysql-driver", url: "https://github.com/vapor/fluent-mysql-driver", from: "4.0.0"),
        
        // JWT issue and verify
        .package(url: "https://github.com/vapor/jwt-kit", from: "4.0.0"),
        
        // A simple package to convert strings to URL slugs.
        .package(url: "https://github.com/twostraws/SwiftSlug", from: "0.3.0"),
        
        // Crypto related functions and helpers for Swift implemented in Swift.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.0.0"),
        
        // Swift logging API
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        
    ],
    targets: [
        .target(name: "Infrastructure", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
            .product(name: "JWTKit", package: "jwt-kit"),
            .product(name: "SwiftSlug", package: "SwiftSlug"),
            .product(name: "CryptoSwift", package: "CryptoSwift"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        .target(name: "Domain", dependencies: [
            .target(name: "Infrastructure"),
        ]),
        .target(name: "Presentation", dependencies: [
            .target(name: "Domain"),
        ]),
        .executableTarget(name: "realworld", dependencies: [
            .target(name: "Presentation"),
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "Presentation"),
        ])
    ]
)

