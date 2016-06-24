import UIKit
import XCTest
import ImageScout

private let expectationTimeOut: TimeInterval = 5

class ImageScoutTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testScoutingJPEG() {
    let scout = ImageScout()
    let expectation = self.expectation(withDescription: "Scout JPEG images")
    let imagePath = Bundle(for: ImageScoutTests.self).urlForResource("scout", withExtension: "jpg")!

    scout.scoutImage(atURL: imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize(width: 500, height: 375), "Image size should be 500 by 375")
      XCTAssertEqual(type, ScoutedImageType.jpeg, "Image type should be JPEG")
      XCTAssertNil(error, "Error should be nil")
    }

    waitForExpectations(withTimeout: expectationTimeOut, handler: nil)
  }

  func testScoutingPNG() {
    let scout = ImageScout()
    let expectation = self.expectation(withDescription: "Scout PNG images")
    let imagePath = Bundle(for: ImageScoutTests.self).urlForResource("scout", withExtension: "png")!

    scout.scoutImage(atURL: imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize(width: 500, height: 375), "Image size should be 500 by 375")
      XCTAssertEqual(type, ScoutedImageType.png, "Image type should be PNG")
      XCTAssertNil(error, "Error should be nil")
    }

    waitForExpectations(withTimeout: expectationTimeOut, handler: nil)
  }

  func testScoutingGIF() {
    let scout = ImageScout()
    let expectation = self.expectation(withDescription: "Scout GIF images")
    let imagePath = Bundle(for: ImageScoutTests.self).urlForResource("scout", withExtension: "gif")!

    scout.scoutImage(atURL: imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize(width: 500, height: 375), "Image size should be 500 by 375")
      XCTAssertEqual(type, ScoutedImageType.gif, "Image type should be GIF")
      XCTAssertNil(error, "Error should be nil")
    }

    waitForExpectations(withTimeout: expectationTimeOut, handler: nil)
  }

  func testScoutingUnsupported() {
    let scout = ImageScout()
    let expectation = self.expectation(withDescription: "Ignore unsupported formats")
    let imagePath = Bundle(for: ImageScoutTests.self).urlForResource("scout", withExtension: "bmp")!

    scout.scoutImage(atURL: imagePath) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSize.zero, "Image size should be 0 by 0")
      XCTAssertEqual(type, ScoutedImageType.unsupported ,"Image type should be Unsupported")
      XCTAssertNotNil(error, "Error should not be nil")
      XCTAssertEqual(error!.code, 102, "Error should describe failure reason")
    }

    waitForExpectations(withTimeout: expectationTimeOut, handler: nil)
  }
}
