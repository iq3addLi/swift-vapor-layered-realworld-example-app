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
        
        // JWT issue and verify
        .package(url: "https://github.com/vapor/jwt-kit", from: "3.0.0"),
    ],
    targets: [
        .target(name: "ProjectFoundation", dependencies: [
            "Vapor",
            "JWT"
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

