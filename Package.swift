// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "swift-vapor-layered-realworld-example",
    products: [
        .library(name: "swift-vapor-layered-realworld-example", targets: ["Presentation"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "ProjectFoundation", dependencies: [
            "Vapor"
        ]),
        .target(name: "Infrastructure", dependencies: [
            "FluentSQLite",
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

