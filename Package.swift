// swift-tools-version:5.0
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
        
        //.package(url: "https://github.com/vapor/mysql-kit.git", from: "3.2.6")
        //.package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
        //.package(url: "https://github.com/IBM-Swift/SwiftKueryMySQL.git", from: "2.0.2") // Happened this issue 😢 https://forums.swift.org/t/logging-module-name-clash-in-vapor-3/25466
    ],
    targets: [
        .target(name: "ProjectFoundation", dependencies: [
            "Vapor"
        ]),
        .target(name: "Infrastructure", dependencies: [
            "FluentMySQL",
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

