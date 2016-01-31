<img src="https://db.tt/yGZRLRqU" alt="Logo" width="300">

# ImageScout [![Travis](https://travis-ci.org/kaishin/ImageScout.svg?branch=master)](https://travis-ci.org/kaishin/ImageScout) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**ImageScout** is a Swift implementation of [fastimage](https://pypi.python.org/pypi/fastimage/0.2.1).
It allows you to find the size and type of a remote image by downloading as little as possible.

#### Why?

Sometimes you need to know the size of a remote image before downloading it, such as
using a custom layout in a `UICollectionView`.

#### How?

ImageScout parses the image data as it is downloaded. As soon as it finds out the size and type of image,
it stops the download. The downloaded data is below 60 KB in most cases.

#### Install

If you use [Carthage](https://github.com/Carthage/Carthage), add this to your `cartfile`: `github "kaishin/ImageScout"`.

If your prefer Git submodules or want to support iOS 7, you want to add the files in `source` to your Xcode project.

#### Usage

The only method you will be using is `scoutImageWithURI()`, with the following full signature:

```swift
func scoutImageWithURI(URI: String, completion: (NSError?, CGSize, ScoutedImageType) -> ())
```

Here's an example:

```swift
let scout = ImageScout()

scout.scoutImageWithURI("http://.../image-scout-logo.png") { error, size, type in
  if let unwrappedError = error {
    println(unwrappedError.code)
  } else {
    println("Size: \(size)")
    println("Type: \(type.rawValue)")
  }
}
```

If the image is not successfully parsed, the error will contain more info about the reason.
In that case, the size is going to be `CGSizeZero` and the type `.Unsupported`.

- Error code **100**: Invalid URI parameter.
- Error code **101**: Image is corrupt or malformatted.
- Error code **102**: Not an image or unsopported image format URL.

It's important to maintain reference to the `ImageScout` instance until the callback completes. If reference is lost, your completion handler will never be executed.

#### Compatibility

- iOS 7.0 and above (Frameworks only work with iOS 8.0)
- Compiles with Xcode 6.1 and above.

#### License

See LICENSE.
