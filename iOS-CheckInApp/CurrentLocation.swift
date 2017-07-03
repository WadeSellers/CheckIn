//
//  CurrentLocation.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 2/6/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

class CurrentLocation: NSObject {
  
  static let sharedInstance = CurrentLocation()
  
  var dispensaryAddress:String?
  var currentLocationName:String?
  var arrayOfStoreLicenses:NSArray?
  var hasRecLicense:Bool = false
  var hasMedLicense:Bool = false
  
  private override init() {
    
  }
  
  func setLicenseOnCurrentLocation() {
    for license in arrayOfStoreLicenses! {
      let substringOfLicense:String = license.substringWithRange(NSMakeRange(0, 4))
      if(substringOfLicense == "402-") {
        hasMedLicense = true
      }
      if(substringOfLicense == "402R") {
        hasRecLicense = true
      }
    }
  }
  
  // MARK: Check store license
  func checkStoreHasLicenses() -> Bool  {
    if let _ = arrayOfStoreLicenses {
      return true;
    } else {
      return false;
    }
  }
  
}
