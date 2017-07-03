//
//  MeteorNetworkingTests.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 3/28/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//
import XCTest
@testable import CheckIn
class MeteorNetworkingTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testProdMeteorUrl() {
    let meteorNetworkingClient = MeteorNetworking.meteor
    let serverUrlToTest = meteorNetworkingClient.ddp.urlString
    print(serverUrlToTest)
    XCTAssertEqual(serverUrlToTest,"wss://pos.flowhub.co/websocket")
  }
  
  
}
