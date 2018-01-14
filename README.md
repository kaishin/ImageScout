<img src="https://github.com/kaishin/ImageScout/blob/swift4/Logo.png?raw=true" alt="Logo" width="200">

# ImageScout

[![GitHub release](https://img.shields.io/github/release/kaishin/ImageScout.svg)](https://github.com/kaishin/ImageScout/releases/latest) ![Bitrise](https://www.bitrise.io/app/c8ec868bb7b6c8c1/status.svg?token=u3EDxXt5jprAmzAT2RteJg&branch=master) ![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg) ![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X-lightgrey.svg)

**ImageScout** is a Swift implementation of [fastimage](https://pypi.python.org/pypi/fastimage/0.2.1).
It allows you to find the size and type of a remote image by downloading as little as possible.

#### Why?

Sometimes you need to know the size of a remote image before downloading it, such as
using a custom layout in a `UICollectionView`.

#### How?

ImageScout parses the image data as it is downloaded. As soon as it finds out the size and type of image,
it stops the download. The downloaded data is below 60 KB in most cases.

#### Install
#### [Carthage](https://github.com/Carthage/Carthage)

- Add the following to your Cartfile: `github "kaishin/ImageScout"`
- Then run `carthage update`
- Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### [CocoaPods](http://cocoapods.org)

- Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html): `pod 'ImageScout'`
- You will also need to make sure you're opting into using frameworks: `use_frameworks!`
- Then run `pod install` with CocoaPods 1.0 or newer.

#### Usage

The only method you will be using is `scoutImageWithURI()`, with the following full signature:

```swift
func scoutImageWithURI(URI: String, completion: (NSError?, CGSize, ScoutedImageType) -> ())
```

Here's an example:

```swift
let scout = ImageScout()

scout.scoutImageWithURI("http://.../image-scout-logo.png") { error, size, type in
  if let error = error {
    print(error.code)
  } else {
    print("Size: \(size)")
    print("Type: \(type.rawValue)")
  }
}
```

If the image is not successfully parsed, the size is going to be `CGSizeZero` and the type `.Unsupported`. The error will contain more info about the reason:

- Error code **100**: Invalid URI parameter.
- Error code **101**: Image is corrupt or malformatted.
- Error code **102**: Not an image or unsopported image format URL.

⚠️ *It's important to keep a strong reference to the `ImageScout` instance until the callback completes. If reference is lost, your completion handler will never be executed.*

#### Compatibility

- Swift 4 / Xcode 9
- iOS 8+
- OS X 10.11

#### License

See LICENSE.
