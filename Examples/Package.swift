// swift-tools-version: 5.10
import Foundation
import PackageDescription

let package = Package(
  name: "swift-shell-examples",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .executable(name: "DecorateOutputExample", targets: ["DecorateOutputExample"]),
    .executable(name: "InputOutputExample", targets: ["InputOutputExample"]),
  ],
  dependencies: [
    .package(path: "../"),
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.1"),
  ],
  targets: [
    .executableTarget(
      name: "DecorateOutputExample",
      dependencies: [
        // NB: The name of the package is the name of the directory where `Package.swift` is located.
        .product(name: "SwiftShell", package: rootDirectoryName),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .executableTarget(
      name: "InputOutputExample",
      dependencies: [
        // NB: The name of the package is the name of the directory where `Package.swift` is located.
        .product(name: "SwiftShell", package: rootDirectoryName),
      ]
    ),
  ]
)

var rootDirectoryName: String {
  URL(filePath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .lastPathComponent
}

extension Target {
  var isLocal: Bool { ![.binary, .system].contains(self.type) }
}

extension BuildSettingCondition {
  static let whenDebug = BuildSettingCondition.when(configuration: .debug)
}

extension SwiftSetting {
  static func enableActorDataRaceChecks(_ condition: BuildSettingCondition? = nil) -> SwiftSetting {
    .unsafeFlags(["-Xfrontend", "-enable-actor-data-race-checks"], condition)
  }
  static func debugTime(_ condition: BuildSettingCondition? = nil) -> SwiftSetting {
    .unsafeFlags(
      ["-Xfrontend", "-debug-time-function-bodies",
       "-Xfrontend", "-debug-time-expression-type-checking"],
      condition
    )
  }
}

for target in package.targets where target.isLocal {
  var swiftSettings = target.swiftSettings ?? []
  swiftSettings.append(.enableActorDataRaceChecks(.whenDebug))
  swiftSettings.append(.debugTime(.whenDebug))
#if !hasFeature(StrictConcurrency)
  swiftSettings.append(.enableUpcomingFeature("StrictConcurrency", .whenDebug))
  swiftSettings.append(.enableExperimentalFeature("StrictConcurrency", .whenDebug))
#endif
#if !hasFeature(GlobalConcurrency)
  swiftSettings.append(.enableUpcomingFeature("GlobalConcurrency", .whenDebug))
#endif
#if !hasFeature(InternalImportsByDefault)
  swiftSettings.append(.enableUpcomingFeature("InternalImportsByDefault", .whenDebug))
#endif
#if !hasFeature(BareSlashRegexLiterals)
  swiftSettings.append(.enableUpcomingFeature("BareSlashRegexLiterals"))
#endif
  target.swiftSettings = swiftSettings
}
