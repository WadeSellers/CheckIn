//
//  AWSNetworkingTests.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 3/28/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation
import XCTest
@testable import CheckIn
class AWSNetworkingTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testEmployeeBucket() {
    let employeeProdBucketToTest:String = AWSNetworking.amazonS3EmployeeManager.requestSerializer.bucket!
    XCTAssertEqual(employeeProdBucketToTest,"flowhub-pos-employee-docs")
  }
  
  func testMedCustomerBucket() {
    let employeeProdBucketToTest:String = AWSNetworking.amazonS3MedCustomerManager.requestSerializer.bucket!
    XCTAssertEqual(employeeProdBucketToTest,"flowhub-pos-med-customer-docs")
  }
  
  
}