// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuilderIO", // Good: Clear, concise name matching the library
    
    platforms: [
        .iOS(.v17), 
    ],
    
    // --- Products ---
    products: [
        .library(
            name: "BuilderIO",
            targets: ["BuilderIO"]
        ),
    ],
    
    // --- Dependencies ---
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
        .package(url: "https://github.com/WeTransfer/Mocker.git", .upToNextMajor(from: "3.0.0")),
    ],
    
    // --- Targets ---
    targets: [
        // Main library target
        .target(
            name: "BuilderIO",
            resources: [
                .process("Resources/Fonts")
            ]
        ),
        
        // Test target
        .testTarget(
            name: "BuilderIOTests",
            dependencies: [
                "BuilderIO", // Dependency on the local library target
                "Mocker",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            resources: [
                .process("Resources") 
            ]
        ),
    ]
)
