//
//  CurrentUser.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 1/7/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class CurrentUser: NSObject {
  
  static let sharedInstance = CurrentUser()
  
  var fullName:String?
  var currentDispensary:String?
  var currentDispensaryAddress:String?
  var position:String?
  var profPic:UIImage?
  var username:String?
  var clientID:String?
  var profPicName:String? 
  
  private override init() {

  }

}
