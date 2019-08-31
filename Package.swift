// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "ImageScout",
  products: [
    .library(
      name: "ImageScout",
      targets: ["ImageScout"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "ImageScout",
      dependencies: []),
    // .testTarget(
    //   name: "ImageScoutTests",
    //   dependencies: ["ImageScout"]),
  ]
)
