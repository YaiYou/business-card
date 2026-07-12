// swift-tools-version: 5.9

// App Playground manifest. Opens and runs in Swift Playgrounds on iPad
// (build + run on-device, no Mac needed) and in Xcode 14+ on macOS.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "RingTimer",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "RingTimer",
            targets: ["AppModule"],
            bundleIdentifier: "com.jamessanders.ringtimer",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
