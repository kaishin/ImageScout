import UIKit
import XCTest

private let expectationTimeOut: NSTimeInterval = 5

class ImageScoutTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testScoutingJPEG() {
    let scout = ImageScout()
    let expectation = expectationWithDescription("Scout JPEG images")
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "jpg")!

    scout.scoutImageWithURL(imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize(width: 500, height: 375), "Image size should be 500 by 375")
      XCTAssertEqual(type, ScoutedImageType.JPEG, "Image type should be JPEG")
      XCTAssertNil(error, "Error should be nil")
    }

    waitForExpectationsWithTimeout(expectationTimeOut, handler: nil)
  }

  func testScoutingPNG() {
    let scout = ImageScout()
    let expectation = expectationWithDescription("Scout PNG images")
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "png")!

    scout.scoutImageWithURL(imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize(width: 500, height: 375), "Image size should be 500 by 375")
      XCTAssertEqual(type, ScoutedImageType.PNG, "Image type should be PNG")
      XCTAssertNil(error, "Error should be nil")
    }

    waitForExpectationsWithTimeout(expectationTimeOut, handler: nil)
  }

  func testScoutingGIF() {
    let scout = ImageScout()
    let expectation = expectationWithDescription("Scout GIF images")
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "gif")!

    scout.scoutImageWithURL(imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize(width: 500, height: 375), "Image size should be 500 by 375")
      XCTAssertEqual(type, ScoutedImageType.GIF, "Image type should be GIF")
      XCTAssertNil(error, "Error should be nil")
    }

    waitForExpectationsWithTimeout(expectationTimeOut, handler: nil)
  }

  func testScoutingUnsupported() {
    let scout = ImageScout()
    let expectation = expectationWithDescription("Ignore unsupported formats")
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "bmp")!

    scout.scoutImageWithURL(imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSizeZero, "Image size should be 0 by 0")
      XCTAssertEqual(type, ScoutedImageType.Unsupported ,"Image type should be Unsupported")
      XCTAssertNotNil(error, "Error should not be nil")
      XCTAssertEqual(error!.code, 102, "Error should describe failure reason")
    }

    waitForExpectationsWithTimeout(expectationTimeOut, handler: nil)
  }
}