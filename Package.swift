// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "swift-vapor-layered-realworld-example",
    products: [
        .executable(name: "swift-vapor-layered-realworld-example", targets: ["Run"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),

        // 🔵 Swift ORM (queries, models, relations, etc)
        .package(url: "https://github.com/iq3addLi/fluent-mysql-driver.git", from: "3.0.2"),
        
        // JWT issue and verify
        .package(url: "https://github.com/vapor/jwt-kit", from: "3.0.0"),
        
        // A simple package to convert strings to URL slugs.
        .package(url: "https://github.com/twostraws/SwiftSlug", from: "0.3.0"),
        
        // Crypto related functions and helpers for Swift implemented in Swift.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.1.2")
    ],
    targets: [
        .target(name: "ProjectFoundation", dependencies: [
            "Vapor"
        ]),
        .target(name: "Infrastructure", dependencies: [
            "FluentMySQL",
            "SwiftSlug",
            "CryptoSwift",
            "JWT",
            "ProjectFoundation"
        ]),
        .target(name: "Domain", dependencies: [
            "Infrastructure",
            "ProjectFoundation"
        ]),
        .target(name: "Presentation", dependencies: [
            "Domain",
            "ProjectFoundation"
        ]),
        .target(name: "Run", dependencies: [
            "Presentation"
        ]),
        .testTarget(name: "AppTests", dependencies: [
            "Presentation"
        ])
    ]
)

