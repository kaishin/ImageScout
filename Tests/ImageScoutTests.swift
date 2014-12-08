//
//  ImageScoutTests.swift
//  ImageScoutTests
//
//  Created by Reda Lemeden on 3/10/14.
//  Copyright (c) 2014 Kaishin & Co. All rights reserved.
//

import UIKit
import XCTest
import ImageScout

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
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "jpg")

    scout.scoutImageWithURI(imagePath!.absoluteString!) { (error, size, type) -> () in
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
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "png")

    scout.scoutImageWithURI(imagePath!.absoluteString!) { (error, size, type) -> () in
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
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "gif")

    scout.scoutImageWithURI(imagePath!.absoluteString!) { (error, size, type) -> () in
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
    let imagePath = NSBundle(forClass: ImageScoutTests.self).URLForResource("scout", withExtension: "bmp")

    scout.scoutImageWithURI(imagePath!.absoluteString!) { (error, size, type) -> () in
      expectation.fulfill()
      XCTAssertEqual(size, CGSizeZero, "Image size should be 0 by 0")
      XCTAssertEqual(type, ScoutedImageType.Unsupported ,"Image type should be Unsupported")
      XCTAssertNotNil(error, "Error should not be nil")
      XCTAssertEqual(error!.code, 102, "Error should describe failure reason")
    }

    waitForExpectationsWithTimeout(expectationTimeOut, handler: nil)
  }
}