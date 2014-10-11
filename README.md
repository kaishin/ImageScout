<img src="https://dl.dropboxusercontent.com/u/148921/assets/image-scout-logo.png" width="200" />

**ImageScout** is a Swift implementation of [fastimage](https://pypi.python.org/pypi/fastimage/0.2.1).
It allows you to find the size and type of a remote image by downloading as little as possible.

#### Why?

Sometimes you need to know the size of a remote image before downloading it, such as
using a custom layout in a `UICollectionView`.

#### How?

ImageScout parses the image data as it is downloaded. As soon as it finds out the size and type of image,
it stops the download. The downloaded data is below 60 KB in most cases.

#### Install

Use Git submodules. You want to add the file(s) in `source` to your Xcode project.

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
    println(unwrappedError.domain)
  } else {
    println("Size: \(size)
    println("Type: \(type.rawValue)")
  }
}
```

If the image is not successfully parsed, the error will contain more info about the reason.
In that case, the size is going to be `CGSizeZero` and the type `.Unsupported`.

- Error code **100**: Invalid URI parameter.
- Error code **101**: Image is corrput or malformatted.
- Error coe **102**: Not an image or unsopported image format URL.

#### Compatibility

- iOS 8+

#### License

See LICENSE.
